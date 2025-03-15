import uvm_pkg::*; 

package bridge_pkg;

   
  
  // ---------------------------- Commonly used Parameters -------------------------------- \\

  // Buses Width
  localparam int HADDR_SIZE = 32;
  localparam int HDATA_SIZE = 32;
  localparam int PADDR_SIZE = 10;
  localparam int PDATA_SIZE = 8;
  localparam int SYNC_DEPTH = 3;


  // HTRANS
  localparam [1:0] IDLE   = 2'b00;
  localparam [1:0] BUSY   = 2'b01;
  localparam [1:0] NONSEQ = 2'b10;
  localparam [1:0] SEQ    = 2'b11;


  // HRESP
  localparam OKAY  = 1'b0 ;
  localparam ERROR = 1'b1 ;

  //HSIZE
  localparam [2:0] HSIZE_B8    = 3'b000,
                   HSIZE_B16   = 3'b001,
                   HSIZE_B32   = 3'b010,
                   HSIZE_B64   = 3'b011,
                   HSIZE_B128  = 3'b100, //4-word line
                   HSIZE_B256  = 3'b101, //8-word line
                   HSIZE_B512  = 3'b110,
                   HSIZE_B1024 = 3'b111,
                   HSIZE_BYTE  = HSIZE_B8,
                   HSIZE_HWORD = HSIZE_B16,
                   HSIZE_WORD  = HSIZE_B32,
                   HSIZE_DWORD = HSIZE_B64;



  // ---------------------------- Commonly used Functions ------------------------------- \\

  // Address Mask Function 
  function logic [6:0] address_mask;
    input integer data_size;
    case (data_size)
          1024: address_mask = 7'b111_1111; 
           512: address_mask = 7'b011_1111;
           256: address_mask = 7'b001_1111;
           128: address_mask = 7'b000_1111;
            64: address_mask = 7'b000_0111;
            32: address_mask = 7'b000_0011;
            16: address_mask = 7'b000_0001;
       default: address_mask = 7'b000_0000;
    endcase
  endfunction 


  // Data Offset Function 
  function logic [9:0] data_offset (input [HADDR_SIZE-1:0] haddr);
    logic [6:0] haddr_masked;
    haddr_masked = haddr & address_mask(HDATA_SIZE);
    data_offset = 8 * haddr_masked;
  endfunction 


  // PSTRB Function 
  function logic [PDATA_SIZE/8-1:0] pstrb;
    input [           2:0] hsize;
    input [PADDR_SIZE-1:0] paddr;

    logic [127:0] full_pstrb;
    logic [  6:0] paddr_masked;

    case (hsize)
       HSIZE_B1024: full_pstrb = {128{1'b1}}; 
       HSIZE_B512 : full_pstrb = { 64{1'b1}};
       HSIZE_B256 : full_pstrb = { 32{1'b1}};
       HSIZE_B128 : full_pstrb = { 16{1'b1}};
       HSIZE_DWORD: full_pstrb = {  8{1'b1}};
       HSIZE_WORD : full_pstrb = {  4{1'b1}};
       HSIZE_HWORD: full_pstrb = {  2{1'b1}};
       default    : full_pstrb = {  1{1'b1}};
    endcase

    paddr_masked = paddr & address_mask(PDATA_SIZE);
    pstrb = full_pstrb << paddr_masked;
  endfunction

  // APB beats number Function
  function logic [6:0] apb_beats;
    input [2:0] hsize;

    case (hsize)
       HSIZE_B1024: apb_beats = 1023/PDATA_SIZE; 
       HSIZE_B512 : apb_beats =  511/PDATA_SIZE;
       HSIZE_B256 : apb_beats =  255/PDATA_SIZE;
       HSIZE_B128 : apb_beats =  127/PDATA_SIZE;
       HSIZE_DWORD: apb_beats =   63/PDATA_SIZE;
       HSIZE_WORD : apb_beats =   31/PDATA_SIZE;
       HSIZE_HWORD: apb_beats =   15/PDATA_SIZE;
       default    : apb_beats =    7/PDATA_SIZE;
    endcase
  endfunction 

  

endpackage 