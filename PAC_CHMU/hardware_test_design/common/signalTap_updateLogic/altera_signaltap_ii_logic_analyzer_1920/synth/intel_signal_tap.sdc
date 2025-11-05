# (C) 2001-2024 Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files from any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Intel Program License Subscription 
# Agreement, Intel FPGA IP License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Intel and sold by 
# Intel or its authorized distributors.  Please refer to the applicable 
# agreement for further details.


# $Revision: #1 
# $Date: 2017/07/31 
# $Author: zkumar 

#-------------------------------------------------------------------------------
# TimeQuest constraints to constrain the timing across asynchronous clock domain crossings.
# The idea is to minimize skew to between stp_status_bits_in_reg_acq (acq domain) and stp_status_bits_out_reg_tck (tck domain)
# 
# CDC takes place between these paths (in intel_stp_status_bits_cdc component)
#

# -----------------------------------------------------------------------------
# This procedure constrains the max_delay (not skew) between the status bit regs.
#
# The hierarchy path to the status_bits CDC instance is required as an 
# argument.
# -----------------------------------------------------------------------------
proc constrain_signaltap_status_bits_max_delay { path } {

    #set the to/from paths for stp_status_bits
    set path_from $path|stp_status_bits_in_reg_acq\[*\]
    set path_to $path|stp_status_bits_out_reg_tck\[*\]

    #check if the paths to be constrained exist or not
    set paths_from [get_registers -nowarn $path_from]
    set paths_to [get_registers -nowarn $path_to]
    set num_status_paths_from [get_collection_size $paths_from]
    set num_status_paths_to [get_collection_size $paths_to]
    ##post_message -type info "DEBUG: paths detected for *stp_status_bits_in_reg_acq* = $num_status_paths_from"
    ##post_message -type info "DEBUG: paths detected for *stp_status_bits_out_reg_tck* = $num_status_paths_to"

    #if either "to" or "from" paths donot exist, exit the .sdc gracefully
    if {$num_status_paths_to > 0} {
        
       set tck_clk [get_fanins $path_to -clock -stop_at_clocks]
       set num_tck_clk [get_collection_size $tck_clk]
    } else {
        set num_tck_clk 0
    }


    if {$num_status_paths_from == 0 || $num_status_paths_to == 0 || $num_tck_clk == 0 } {
    
        post_message -type info "Status exchange path between acquisition clock and communication clock in the Signal Tap instance, [get_current_instance] is synthesized out.  No constraint is added on this path."
        
    } else {
    
        post_message -type info "Constraints on the CDC paths between acquisition clock and communication clock are created in the Signal Tap instance, [get_current_instance]"
        #call to function to get the tck domain name and period
        ## post_message -type warning "DEBUG: my path = $path|stp_status_bits_out_reg_tck*"
        set max_delay_prd [expr [get_tck_info $path_to $tck_clk]]
        ## post_message -type warning "DEBUG: max delay is 1xtck_clk_prd = $max_delay_prd"

        #set the max delay as function of dst clk period (i.e. tck clk prd) so that -
        #1) to make the delay settings more relaxed (more than 1ns), between i/p and o/p status bits 
        #2) to ensure the max delay can be used when acq clk > tck clk and vice-versa
        #max delay is 1xtck clk period (because valid bit takes ~3 cycles to go from acq to tck domain)

        set_max_delay -from $paths_from  -to $paths_to  $max_delay_prd
    
    }  

}

# -----------------------------------------------------------------------------
# This procedure is to find out the tck clk name and period
#
# The hierarchy path to the status_bits CDC instance is required as an 
# argument.
# -----------------------------------------------------------------------------
proc get_tck_info { filter tck_clk_col} {
    ## post_message -type warning "DEBUG: Search for $filter"
    ## post_message -type warning "DEBUG: my_tck_clk = $tck_clk_col"

    # A10 & S10 support max 33.3Mhz clock (default, in case tck clk prd is not defined)
    set default_tck_prd 30
    
    foreach_in_collection clk $tck_clk_col {
        set tck_clk_node_name [get_node_info -name $clk]
        ## post_message -type warning "DEBUG: tck domain clk name: $tck_clk_node_name"
        set clks [get_clocks -nowarn -of_objects [get_registers $filter]]
        ## post_message -type warning "DEBUG: $clks [llength $clks] get_clocks -of_objects \[get_registers $filter\]"

        ##check if tck clk period has been previously declared or not
        if {[get_collection_size $clks] == 0} {
                ## post_message -type warning "DEBUG: tck clk period is not defined, setting max delay to 30ns (default 33MHz tck)"
                post_message -type info "The clock period of '$tck_clk_node_name' used in the Signal Tap instance, [get_current_instance] is not defined, setting max delay to 30ns (default 33MHz tck)"
                set tck_clk_prd $default_tck_prd
                ## post_message -type warning "DEBUG: tck domain period (default): $tck_clk_prd"
        } else {
            # In the case of multiple clock definitions, arbitrarily use the first clock in the list
            foreach_in_collection clk $clks {
                set tck_clk_prd [get_clock_info $clk -period]
                ## post_message -type warning "DEBUG: tck domain period: $tck_clk_prd"  
                break
	    }
        }        

       
    }

    return $tck_clk_prd

}



constrain_signaltap_status_bits_max_delay "[get_current_instance]|sld_signaltap_inst|sld_signaltap_body|sld_signaltap_body|jtag_acq_clk_xing|intel_stp_status_bits_cdc_u1"
