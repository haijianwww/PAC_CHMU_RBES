-- (C) 2001-2024 Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions and other 
-- software and tools, and its AMPP partner logic functions, and any output 
-- files from any of the foregoing (including device programming or simulation 
-- files), and any associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License Subscription 
-- Agreement, Intel FPGA IP License Agreement, or other applicable 
-- license agreement, including, without limitation, that your use is for the 
-- sole purpose of programming logic devices manufactured by Intel and sold by 
-- Intel or its authorized distributors.  Please refer to the applicable 
-- agreement for further details.


package sld_signaltap_pack is
	constant SLD_IR_BITS					: natural := 10;	-- Constant value.  DO NOT CHANGE.
end package sld_signaltap_pack;

library ieee;
use ieee.std_logic_1164.all;
use work.sld_signaltap_pack.all;

entity sld_signaltap_syn is
	generic 
	(
		lpm_type					: string := "sld_signaltap";

		SLD_NODE_INFO				: natural := 0;		-- The NODE ID to uniquely identify this node on the hub.
		
		SLD_SECTION_ID					: string := "hdl_signaltap_0";	-- This name was chosen so it wouldn't clash with any auto_signaltap_xxx agent(s) from .stp file(s)

		-- HIP_AUTO_GEN_TAG: version_definition
		
		-- ELA Input Width Parameters
		SLD_DATA_BITS				: natural := 1;		-- The ELA data input width in bits
		SLD_TRIGGER_BITS			: natural := 1;		-- The ELA trigger input width in bits
				
		-- Consistency Check Parameters
		SLD_NODE_CRC_BITS			: natural := 32;
		SLD_NODE_CRC_HIWORD			: natural := 41394;	-- High byte of the CRC word
		SLD_NODE_CRC_LOWORD			: natural := 50132;	-- Low byte of the CRC word
		SLD_INCREMENTAL_ROUTING		: natural := 0;		-- Indicate whether incremental CRC register is used

		-- Acquisition Buffer Parameters
		SLD_SAMPLE_DEPTH			: natural := 16;	-- Memory buffer size
		SLD_SEGMENT_SIZE			: natural := 0;	-- Size of each segment
		SLD_RAM_BLOCK_TYPE			: string := "AUTO";	-- Memory buffer type on the device
		SLD_STATE_BITS				: natural := 11;		-- bits needed for state encoding
		
		SLD_BUFFER_FULL_STOP		: natural := 1;		-- if set to 1, once last segment full auto stops acquisition
		
		--obsoleted
		SLD_MEM_ADDRESS_BITS		: natural := 7;		-- Memory buffer address width log2(SLD_SAMPLE_DEPTH)
		SLD_DATA_BIT_CNTR_BITS		: natural := 4;		-- = ceil(log2(SLD_DATA_BITS)) + 1
		
		-- Trigger Control Parameters
		SLD_TRIGGER_LEVEL			: natural := 10;		-- Number of trigger levels that will be used to stop the data acquisition
		SLD_TRIGGER_IN_ENABLED		: natural := 0;		-- Indicate whether to generate the trigger_in logic.  Generate if it is 1; not, otherwise.
		SLD_HPS_TRIGGER_IN_ENABLED	: natural := 0;		-- Indicate whether to generate the trigger_in logic from HPS.  Generate if it is 1; not, otherwise.
		SLD_HPS_TRIGGER_OUT_ENABLED	: natural := 0;		-- Indicate whether to generate the trigger_out logic driving HPS.  Generate if it is 1; not, otherwise.
		SLD_HPS_EVENT_ENABLED		: natural := 0;		-- Indicate whether to generate the event logic driving HPS.  Generate if it is 1; not, otherwise.
		SLD_HPS_EVENT_ID			: natural := 0;		-- Specifies the event line index, if event logic is created driving HPS.
		SLD_ADVANCED_TRIGGER_ENTITY	: string := "basic";	-- Comma delimited entity name for each advanced trigger level, or "basic" if level is using standard mode
		SLD_TRIGGER_LEVEL_PIPELINE	: natural := 1;		-- Length of trigger level pipeline.
		SLD_TRIGGER_PIPELINE	    : natural := 0;
		SLD_RAM_PIPELINE            : natural := 0;
		SLD_COUNTER_PIPELINE        : natural := 0;
		SLD_ENABLE_ADVANCED_TRIGGER	: natural := 0;		-- Indicate whether to deploy multi-level basic trigger level or advanced trigger level
		SLD_ADVANCED_TRIGGER_1		: string := "NONE";	-- advanced trigger expression
		SLD_ADVANCED_TRIGGER_2		: string := "NONE";	-- advanced trigger expression
		SLD_ADVANCED_TRIGGER_3		: string := "NONE";	-- advanced trigger expression
		SLD_ADVANCED_TRIGGER_4		: string := "NONE";	-- advanced trigger expression
		SLD_ADVANCED_TRIGGER_5		: string := "NONE";	-- advanced trigger expression
		SLD_ADVANCED_TRIGGER_6		: string := "NONE";	-- advanced trigger expression
		SLD_ADVANCED_TRIGGER_7		: string := "NONE";	-- advanced trigger expression
		SLD_ADVANCED_TRIGGER_8		: string := "NONE";	-- advanced trigger expression
		SLD_ADVANCED_TRIGGER_9		: string := "NONE";	-- advanced trigger expression
		SLD_ADVANCED_TRIGGER_10		: string := "NONE";	-- advanced trigger expression
		SLD_INVERSION_MASK_LENGTH	: integer := 1;		-- length of inversion mask
		SLD_INVERSION_MASK			: std_logic_vector := "0"; --inversion mask
		SLD_POWER_UP_TRIGGER		: natural := 0;		-- power-up trigger mode
		SLD_STATE_FLOW_MGR_ENTITY	: string := "state_flow_mgr_entity.vhd";	--name of generated entity controlling state flow
		SLD_STATE_FLOW_USE_GENERATED	: natural := 0;
		SLD_CURRENT_RESOURCE_WIDTH	: natural := 0;
		SLD_ATTRIBUTE_MEM_MODE		: string := "OFF";
        
		
		--Storage Qualifier Parameters
		SLD_STORAGE_QUALIFIER_BITS	: natural := 1;
		SLD_STORAGE_QUALIFIER_GAP_RECORD : natural := 0;
		SLD_STORAGE_QUALIFIER_MODE	: string := "OFF";
		SLD_STORAGE_QUALIFIER_ENABLE_ADVANCED_CONDITION	: natural := 0;		-- Indicate whether to deploy multi-level basic condition level or advanced condition level
		SLD_STORAGE_QUALIFIER_INVERSION_MASK_LENGTH	: natural := 0;
		SLD_STORAGE_QUALIFIER_ADVANCED_CONDITION_ENTITY	: string := "basic";
		SLD_STORAGE_QUALIFIER_PIPELINE : natural := 0
				
	);

	port
	(
		acq_clk						: in std_logic;		-- The acquisition clock
		acq_data_in					: in std_logic_vector (SLD_DATA_BITS-1 downto 0) := (others => '0');	-- The data input source to be acquired.
		acq_trigger_in				: in std_logic_vector (SLD_TRIGGER_BITS-1 downto 0) := (others => '0');	-- The trigger input source to be analyzed.
		trigger_in					: in std_logic := '0';		-- The trigger-in source
		storage_enable				: in std_logic := '0';		-- Storage Qualifier control when in PORT mode
		acq_data_out				: out std_logic_vector (SLD_DATA_BITS-1 downto 0);	-- SHIFT to the JTAG HUB.  Indicate whether it is in shift state.
		trigger_out					: out std_logic 	-- Indicating when a match occurred.	-- SHIFT from the JTAG HUB.  Indicate whether it is in shift state.
	);

end entity sld_signaltap_syn;

architecture rtl of sld_signaltap_syn is
	component sld_signaltap is
        generic 
        (
            lpm_type					: string := "sld_signaltap";

            SLD_NODE_INFO				: natural := 0;		-- The NODE ID to uniquely identify this node on the hub.
            
            SLD_SECTION_ID					: string := "hdl_signaltap_0";	-- This name was chosen so it wouldn't clash with any auto_signaltap_xxx agent(s) from .stp file(s)

            -- HIP_AUTO_GEN_TAG: version_definition
            
            -- ELA Input Width Parameters
            SLD_DATA_BITS				: natural := 1;		-- The ELA data input width in bits
            SLD_TRIGGER_BITS			: natural := 1;		-- The ELA trigger input width in bits
                    
            -- Consistency Check Parameters
            SLD_NODE_CRC_BITS			: natural := 32;
            SLD_NODE_CRC_HIWORD			: natural := 41394;	-- High byte of the CRC word
            SLD_NODE_CRC_LOWORD			: natural := 50132;	-- Low byte of the CRC word
            SLD_INCREMENTAL_ROUTING		: natural := 0;		-- Indicate whether incremental CRC register is used

            -- Acquisition Buffer Parameters
            SLD_SAMPLE_DEPTH			: natural := 16;	-- Memory buffer size
            SLD_SEGMENT_SIZE			: natural := 0;	-- Size of each segment
            SLD_RAM_BLOCK_TYPE			: string := "AUTO";	-- Memory buffer type on the device
            SLD_STATE_BITS				: natural := 11;		-- bits needed for state encoding
            
            SLD_BUFFER_FULL_STOP		: natural := 1;		-- if set to 1, once last segment full auto stops acquisition
            
            --obsoleted
            SLD_MEM_ADDRESS_BITS		: natural := 7;		-- Memory buffer address width log2(SLD_SAMPLE_DEPTH)
            SLD_DATA_BIT_CNTR_BITS		: natural := 4;		-- = ceil(log2(SLD_DATA_BITS)) + 1
            
            -- Trigger Control Parameters
            SLD_TRIGGER_LEVEL			: natural := 10;		-- Number of trigger levels that will be used to stop the data acquisition
            SLD_TRIGGER_IN_ENABLED		: natural := 0;		-- Indicate whether to generate the trigger_in logic.  Generate if it is 1; not, otherwise.
            SLD_HPS_TRIGGER_IN_ENABLED	: natural := 0;		-- Indicate whether to generate the trigger_in logic from HPS.  Generate if it is 1; not, otherwise.
            SLD_HPS_TRIGGER_OUT_ENABLED	: natural := 0;		-- Indicate whether to generate the trigger_out logic driving HPS.  Generate if it is 1; not, otherwise.
            SLD_HPS_EVENT_ENABLED		: natural := 0;		-- Indicate whether to generate the event logic driving HPS.  Generate if it is 1; not, otherwise.
            SLD_HPS_EVENT_ID			: natural := 0;		-- Specifies the event line index, if event logic is created driving HPS.
            SLD_ADVANCED_TRIGGER_ENTITY	: string := "basic";	-- Comma delimited entity name for each advanced trigger level, or "basic" if level is using standard mode
            SLD_TRIGGER_LEVEL_PIPELINE	: natural := 1;		-- Length of trigger level pipeline.
            SLD_TRIGGER_PIPELINE	    : natural := 0;
            SLD_RAM_PIPELINE            : natural := 0;
            SLD_COUNTER_PIPELINE        : natural := 0;
            SLD_ENABLE_ADVANCED_TRIGGER	: natural := 0;		-- Indicate whether to deploy multi-level basic trigger level or advanced trigger level
            SLD_ADVANCED_TRIGGER_1		: string := "NONE";	-- advanced trigger expression
            SLD_ADVANCED_TRIGGER_2		: string := "NONE";	-- advanced trigger expression
            SLD_ADVANCED_TRIGGER_3		: string := "NONE";	-- advanced trigger expression
            SLD_ADVANCED_TRIGGER_4		: string := "NONE";	-- advanced trigger expression
            SLD_ADVANCED_TRIGGER_5		: string := "NONE";	-- advanced trigger expression
            SLD_ADVANCED_TRIGGER_6		: string := "NONE";	-- advanced trigger expression
            SLD_ADVANCED_TRIGGER_7		: string := "NONE";	-- advanced trigger expression
            SLD_ADVANCED_TRIGGER_8		: string := "NONE";	-- advanced trigger expression
            SLD_ADVANCED_TRIGGER_9		: string := "NONE";	-- advanced trigger expression
            SLD_ADVANCED_TRIGGER_10		: string := "NONE";	-- advanced trigger expression
            SLD_INVERSION_MASK_LENGTH	: integer := 1;		-- length of inversion mask
            SLD_INVERSION_MASK			: std_logic_vector := "0"; --inversion mask
            SLD_POWER_UP_TRIGGER		: natural := 0;		-- power-up trigger mode
            SLD_STATE_FLOW_MGR_ENTITY	: string := "state_flow_mgr_entity.vhd";	--name of generated entity controlling state flow
            SLD_STATE_FLOW_USE_GENERATED	: natural := 0;
            SLD_CURRENT_RESOURCE_WIDTH	: natural := 0;
            SLD_ATTRIBUTE_MEM_MODE		: string := "OFF";
            
            
            --Storage Qualifier Parameters
            SLD_STORAGE_QUALIFIER_BITS	: natural := 1;
            SLD_STORAGE_QUALIFIER_GAP_RECORD : natural := 0;
            SLD_STORAGE_QUALIFIER_MODE	: string := "OFF";
            SLD_STORAGE_QUALIFIER_ENABLE_ADVANCED_CONDITION	: natural := 0;		-- Indicate whether to deploy multi-level basic condition level or advanced condition level
            SLD_STORAGE_QUALIFIER_INVERSION_MASK_LENGTH	: natural := 0;
            SLD_STORAGE_QUALIFIER_ADVANCED_CONDITION_ENTITY	: string := "basic";
            SLD_STORAGE_QUALIFIER_PIPELINE : natural := 0   
        );

        port 
        (
            acq_clk						: in std_logic;		-- The acquisition clock
            acq_data_in					: in std_logic_vector (SLD_DATA_BITS-1 downto 0) := (others => '0');	-- The data input source to be acquired.
            acq_trigger_in				: in std_logic_vector (SLD_TRIGGER_BITS-1 downto 0) := (others => '0');	-- The trigger input source to be analyzed.
            acq_storage_qualifier_in	: in std_logic_vector (SLD_STORAGE_QUALIFIER_BITS-1 downto 0) := (others => '0'); --the storage qualifier condition module input source signals
            trigger_in					: in std_logic := '0';		-- The trigger-in source
            crc							: in std_logic_vector (SLD_NODE_CRC_BITS-1 downto 0) := (others => '0');	-- The incremental CRC data input
            storage_enable				: in std_logic := '0';		-- Storage Qualifier control when in PORT mode
            raw_tck						: in std_logic := '0';		-- Real TCK from the JTAG HUB.
            tdi							: in std_logic := '0';		-- TDI from the JTAG HUB.  It gets the data from JTAG TDI.
            usr1						: in std_logic := '0';		-- USR1 from the JTAG HUB.  Indicate whether it is in USER1 or USER0
            jtag_state_cdr				: in std_logic := '0';		-- CDR from the JTAG HUB.  Indicate whether it is in Capture_DR state.
            jtag_state_sdr				: in std_logic := '0';		-- SDR from the JTAG HUB.  Indicate whether it is in Shift_DR state.
            jtag_state_e1dr				: in std_logic := '0';		-- EDR from the JTAG HUB.  Indicate whether it is in Exit1_DR state.
            jtag_state_udr				: in std_logic := '0';		-- UDR from the JTAG HUB.  Indicate whether it is in Update_DR state.
            jtag_state_uir				: in std_logic := '0';		-- UIR from the JTAG HUB.  Indicate whether it is in Update_IR state.
            clr							: in std_logic := '0';		-- CLR from the JTAG HUB.  Indicate whether hub request global reset.
            ena							: in std_logic := '0';		-- ENA from the JTAG HUB.  Indicate whether this node should establish JTAG chain.
            ir_in						: in std_logic_vector (SLD_IR_BITS-1 downto 0) := (others => '0');	-- IR_OUT from the JTAG HUB.  It hold the current instruction for the node.
            
            -- (Begin extra ports) QSYS requires that both ends of a conduit match up so these ports have been added
            -- to make our conduit match the standard one
            jtag_state_tlr 				: in std_logic := '0';
            jtag_state_rti 				: in std_logic := '0';
            jtag_state_sdrs				: in std_logic := '0';
            jtag_state_pdr 				: in std_logic := '0';
            jtag_state_e2dr				: in std_logic := '0';
            jtag_state_sirs				: in std_logic := '0';
            jtag_state_cir 				: in std_logic := '0';
            jtag_state_sir				: in std_logic := '0';
            jtag_state_e1ir				: in std_logic := '0';
            jtag_state_pir 				: in std_logic := '0';
            jtag_state_e2ir				: in std_logic := '0';
            tms							: in std_logic := '0';
            clrn						: in std_logic := '0';
            irq							: out std_logic;
            -- (End extra ports)
            
            vcc							: out std_logic;
            gnd							: out std_logic;
            
            ir_out						: out std_logic_vector (SLD_IR_BITS-1 downto 0);	-- IR_IN to the JTAG HUB.  It supplies the updated value for IR_IN.
            tdo							: out std_logic;	-- TDO to the JTAG HUB.  It supplies the data to JTAG TDO.

            acq_data_out				: out std_logic_vector (SLD_DATA_BITS-1 downto 0);	-- SHIFT to the JTAG HUB.  Indicate whether it is in shift state.
            acq_trigger_out				: out std_logic_vector (SLD_TRIGGER_BITS-1 downto 0);	-- SHIFT to the JTAG HUB.  Indicate whether it is in shift state.
            trigger_out					: out std_logic 	-- Indicating when a match occurred.	-- SHIFT from the JTAG HUB.  Indicate whether it is in shift state.
        );
    end component sld_signaltap;

begin

    sld_signaltap_inst : sld_signaltap
		generic map
		(
            lpm_type                    => lpm_type,
            SLD_NODE_INFO               => SLD_NODE_INFO,
            SLD_SECTION_ID              => SLD_SECTION_ID,
			SLD_DATA_BITS				=> SLD_DATA_BITS,
			SLD_TRIGGER_BITS			=> SLD_TRIGGER_BITS,
			SLD_NODE_CRC_BITS			=> SLD_NODE_CRC_BITS,
			SLD_NODE_CRC_HIWORD			=> SLD_NODE_CRC_HIWORD,
			SLD_NODE_CRC_LOWORD			=> SLD_NODE_CRC_LOWORD,
			SLD_INCREMENTAL_ROUTING		=> SLD_INCREMENTAL_ROUTING,
			SLD_SAMPLE_DEPTH			=> SLD_SAMPLE_DEPTH,
			SLD_SEGMENT_SIZE			=> SLD_SEGMENT_SIZE,
			SLD_RAM_BLOCK_TYPE			=> SLD_RAM_BLOCK_TYPE,
			SLD_TRIGGER_LEVEL			=> SLD_TRIGGER_LEVEL,
			SLD_TRIGGER_IN_ENABLED		=> SLD_TRIGGER_IN_ENABLED,
			SLD_HPS_TRIGGER_IN_ENABLED	=> SLD_HPS_TRIGGER_IN_ENABLED,
			SLD_HPS_TRIGGER_OUT_ENABLED	=> SLD_HPS_TRIGGER_OUT_ENABLED,
			SLD_HPS_EVENT_ENABLED		=> SLD_HPS_EVENT_ENABLED,
			SLD_HPS_EVENT_ID			=> SLD_HPS_EVENT_ID,
			SLD_ADVANCED_TRIGGER_ENTITY	=> SLD_ADVANCED_TRIGGER_ENTITY,
			SLD_TRIGGER_LEVEL_PIPELINE	=> SLD_TRIGGER_LEVEL_PIPELINE,
			SLD_TRIGGER_PIPELINE	=> SLD_TRIGGER_PIPELINE,
			SLD_RAM_PIPELINE => SLD_RAM_PIPELINE,
			SLD_COUNTER_PIPELINE => SLD_COUNTER_PIPELINE,
			SLD_ENABLE_ADVANCED_TRIGGER	=> SLD_ENABLE_ADVANCED_TRIGGER,
			SLD_ADVANCED_TRIGGER_1		=> SLD_ADVANCED_TRIGGER_1,
			SLD_ADVANCED_TRIGGER_2		=> SLD_ADVANCED_TRIGGER_2,
			SLD_ADVANCED_TRIGGER_3		=> SLD_ADVANCED_TRIGGER_3,
			SLD_ADVANCED_TRIGGER_4		=> SLD_ADVANCED_TRIGGER_4,
			SLD_ADVANCED_TRIGGER_5		=> SLD_ADVANCED_TRIGGER_5,
			SLD_ADVANCED_TRIGGER_6		=> SLD_ADVANCED_TRIGGER_6,
			SLD_ADVANCED_TRIGGER_7		=> SLD_ADVANCED_TRIGGER_7,
			SLD_ADVANCED_TRIGGER_8		=> SLD_ADVANCED_TRIGGER_8,
			SLD_ADVANCED_TRIGGER_9		=> SLD_ADVANCED_TRIGGER_9,
			SLD_ADVANCED_TRIGGER_10		=> SLD_ADVANCED_TRIGGER_10,
			SLD_INVERSION_MASK_LENGTH	=> SLD_INVERSION_MASK_LENGTH,
			SLD_INVERSION_MASK			=> SLD_INVERSION_MASK,
			SLD_POWER_UP_TRIGGER		=> SLD_POWER_UP_TRIGGER,
			SLD_STATE_BITS				=> SLD_STATE_BITS,
			SLD_STATE_FLOW_MGR_ENTITY	=> SLD_STATE_FLOW_MGR_ENTITY,
			SLD_STATE_FLOW_USE_GENERATED	=> SLD_STATE_FLOW_USE_GENERATED,
			SLD_BUFFER_FULL_STOP		=> SLD_BUFFER_FULL_STOP,
			SLD_CURRENT_RESOURCE_WIDTH	=> SLD_CURRENT_RESOURCE_WIDTH,
			SLD_ATTRIBUTE_MEM_MODE		=> SLD_ATTRIBUTE_MEM_MODE,
			SLD_STORAGE_QUALIFIER_BITS	=> SLD_STORAGE_QUALIFIER_BITS,
			SLD_STORAGE_QUALIFIER_GAP_RECORD	=> SLD_STORAGE_QUALIFIER_GAP_RECORD,
			SLD_STORAGE_QUALIFIER_MODE	=> SLD_STORAGE_QUALIFIER_MODE,
			SLD_STORAGE_QUALIFIER_ENABLE_ADVANCED_CONDITION => SLD_STORAGE_QUALIFIER_ENABLE_ADVANCED_CONDITION,
			SLD_STORAGE_QUALIFIER_INVERSION_MASK_LENGTH	=> SLD_STORAGE_QUALIFIER_INVERSION_MASK_LENGTH,
			SLD_STORAGE_QUALIFIER_ADVANCED_CONDITION_ENTITY => SLD_STORAGE_QUALIFIER_ADVANCED_CONDITION_ENTITY,
			SLD_STORAGE_QUALIFIER_PIPELINE	=> SLD_STORAGE_QUALIFIER_PIPELINE
		)
		port map
		(
			acq_clk						=> acq_clk,
			acq_data_in					=> acq_data_in,
			acq_trigger_in				=> acq_trigger_in,
			storage_enable				=> storage_enable,
			trigger_in					=> trigger_in,
			acq_data_out				=> acq_data_out,
			trigger_out					=> trigger_out
		);
	
end architecture rtl;
-- pragma questa_oem_00 "uASR1sd/9pKb0QH+cNA/ieJbqeLJNyxgeWHlmBW2QbP4oir95C/p8PyyNmoth0GK33UTgZVGVbP/+Lyd/XQce++inBgVav1TbQMuUy7uYimbO3mWGWcgIAlS7PVsswnLJUilWRcG1mA7YoQws3xXAAudIE4jdA5x7qo6pctl5rAUaRh3TK+m7Bng5sxkBCTKBhtVAmA9AnAx7Gida8IhcYiMLvVr+U58cr5rk2w79/DkuELuaui8pqNvJxpFuR/cv3pTPCU3WyypfR7J2bsxuBVFf/1OCFShdw3Y8rLVKQ6fkFGSwXEOEsJbGyVPDenYn9hIfyiY5tXh6g4AtLnzsS+CR/lr9i+VL5wmQ3i2vcE3HL2lyT2MEs25+b4bveazD2VOG2/dW0hn80BHnmrjlV7hu1GY0S05Qu/T+puI71hGY8d5kPpe1Dekm8yIzs8rCeSue93sVEQwAhztL4RwGJ9D764TNAqBBLO/VewKVq5jXcY0CtpSu476kQ19eK/uQHE8mZw4ZpOuaBy6amQ8Ofmscie3jg88UVZhCGsjLpyur9jAuau4tAeZseRWaQpgbP2TPLUSQUAl2ndtVPFn8KBLnI6sij3oEQjkfKaaQSFarYvmafmdyNis3PSJTz2MPwCy+M7cT2N7ZSHOxgnqpL53k8AEPrFvRQhCdzmKDaMW3im/gUZqWMHJgfNIkxrUBQ+mKUuNuxwFX5zeKFidEIe6YsdvxxlEvkXezJ3ugKOgbWU3GjFpy4A7xIkdrNr1w5Pk44mEEvyG6dNFUykxHMBkSqeUqxJcfmwi47G0XJEQTXzupKhZNuFjrYlaBbH+dlANZUTCVftNOdkUyTtyqlp2YpkkO/rcmTnC4H3NyEbDSmhFi393ZUScc7KyLpRYkPVwmISfih5fQjLUsF0aTgQpCeAPiaTRbd1XWQ+qARMJaigBt4w2SfbduIcSIni6dGWYlXi1YDT2CoJwYyhKIe2ZQsg/oy5jC+5l1BUGhoTDZOE91cXLyvO+8V2HGIXn"