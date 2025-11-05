// (C) 2001-2024 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// Copyright 2023 Intel Corporation.
//
// THIS SOFTWARE MAY CONTAIN PREPRODUCTION CODE AND IS PROVIDED BY THE
// COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
// WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
// WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
// OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
// EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
///////////////////////////////////////////////////////////////////////

package clst_pkg;

// @@copy for common_afu_pkg@@start
    typedef enum logic [3:0] {
        CLSTSTATE_I            = 4'h0,
        CLSTSTATE_S            = 4'h1,
        CLSTSTATE_E            = 4'h2,
        CLSTSTATE_M            = 4'h3,
        CLSTSTATE_IMPRECISE_IS = 4'h4,
        CLSTSTATE_IMPRECISE_IM = 4'h5,
        CLSTSTATE_IMPRECISE_EM = 4'h6,
        CLSTSTATE_UNKNOWN      = 4'h7,
        CLSTSTATE_RSVD_08      = 4'h8,
        CLSTSTATE_RSVD_09      = 4'h9,
        CLSTSTATE_RSVD_10      = 4'hA,
        CLSTSTATE_RSVD_11      = 4'hB,
        CLSTSTATE_RSVD_12      = 4'hC,
        CLSTSTATE_RSVD_13      = 4'hD,
        CLSTSTATE_RSVD_14      = 4'hE,
        CLSTSTATE_ILLEGAL      = 4'hF
    } clst_state_e;

    typedef enum logic [1:0] {
        CLSTSNP_CURR    = 2'd0,
        CLSTSNP_DATA    = 2'd1,
        CLSTSNP_INV     = 2'd2,
        CLSTSNP_ILLEGAL = 2'd3
    } clst_snp_e;

    typedef enum logic {
        CLSTCHGSRC_CAFU = 1'b0,
        CLSTCHGSRC_HOST = 1'b1
    } clst_chg_src_e;

    typedef struct packed {
        logic [2:0]            Rsvd;
        clst_chg_src_e         ChgSrc;
        clst_state_e           HostFinalState;
        clst_state_e           HostOrigState;
        clst_state_e           IPFinalState;
        clst_state_e           IPOrigState;
        logic [51:0]  Addr;
    } clst_attr_t;
// @@copy for common_afu_pkg@@end

endpackage: clst_pkg
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "EknmHwQp1Im7e42VTEW4oP2YlkjZ4q1qxNf0pFfjUqCitHkH39CYcFkwSiDngDquknlwOs0cV09OWg1Vqr9AJzKHl9u3jmr1ART1KkS8wXukVlgHSVfd16n8/T9v5gAWwkVERtgG7ZXREFE2Ma4KnGT/aFGmA6j1B8XDnuCKFAsk/YDTkJMsrKEHO5zzdNk6r7SaThxY+E0ejgfrwMULALf2OnQu+lk4HNYpq3cSGSQYx0z3TNpeLV0lLQdHQLYvGLUBcSe2XMsteaXfn+Ta/20wG5dgS8XRc05Ds9zQumoXLmb1zZwQHgeiiUTos76LWUPpZQicTtdc5yuDbD1AZQsvKiFfrpJA69Ka0425TG5PsDM03oIGW5hjpabdVnl6xb+wEt6XMI83DuWHqTZdFqb8cOXFgvAxibXpVWfvURxuQi9+Hl4Ce8cXcqbaQKY/mK+/venhnOpOHCRfKFdBYaSiIdTFYtu3bVqR7BvKNZpLA/x3FeeOusWL5OCHiOx0D8LJXesLYMRmhT4dOleYSB+lwrTh4voe+Yg2mP1ZD/ww76vQKZvF3GLZC9g8RSZ18uE0gmk2XWoBsHGMS2zAiqcuwb5Ho5Dx1qHoG2tjwaCPIf5NlDGN2OIoWibVCaVD4OYPNmh+GGDdxlIlIPWt5Kkkldk+xUda6btFGrVl6xIH+EJHotppH5G7Nv5p1XBanKAONgsmatZpRVy5DOek2oZXa3kZ8d1MLFYlI9Xy5YXj/tzCl0wikcwWGOeXwbdzk0hIjYDI2+18Xs2owoaLwar+8Qc8LfUDDcN+aVsxWZ8LdQmv923w4hyqyRzUfMUXPrzUucBGxqsK8/3kthSozUtHzDv67EA6LNhyOPYwJyeaxRRG1pkLQ8Th3BlBRJlDxY/Q1DbiuJnvssRdXOmTwPwVSTGECwD+/S1K0ZhMQVBTJvof8lyRAggSXDbuDzKhIKkTGI//5MZqCyIj1XujKrWK+5sMroLKynVvmISYvkXT+wcBycSpUWFmFPvoritE"
`endif