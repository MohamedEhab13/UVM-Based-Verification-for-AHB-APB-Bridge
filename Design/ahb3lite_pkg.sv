package ahb3lite_pkg;

  localparam       HTRANS_SIZE   = 2;
  localparam       HSIZE_SIZE    = 3;
  localparam       HBURST_SIZE   = 3;
  localparam       HPROT_SIZE    = 4;

  //HTRANS
  localparam [1:0] HTRANS_IDLE   = 2'b00,
                   HTRANS_BUSY   = 2'b01,
                   HTRANS_NONSEQ = 2'b10,
                   HTRANS_SEQ    = 2'b11;

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

  //HBURST
  localparam [2:0] HBURST_SINGLE = 3'b000,
                   HBURST_INCR   = 3'b001,
                   HBURST_WRAP4  = 3'b010,
                   HBURST_INCR4  = 3'b011,
                   HBURST_WRAP8  = 3'b100,
                   HBURST_INCR8  = 3'b101,
                   HBURST_WRAP16 = 3'b110,
                   HBURST_INCR16 = 3'b111;

  //HPROT
  localparam [3:0] HPROT_OPCODE         = 4'b0000,
                   HPROT_DATA           = 4'b0001,
                   HPROT_USER           = 4'b0000,
                   HPROT_PRIVILEGED     = 4'b0010,
                   HPROT_NON_BUFFERABLE = 4'b0000,
                   HPROT_BUFFERABLE     = 4'b0100,
                   HPROT_NON_CACHEABLE  = 4'b0000,
                   HPROT_CACHEABLE      = 4'b1000;


  //PPROT
  localparam [2:0] PPROT_NORMAL      = 3'b000,
                   PPROT_PRIVILEGED  = 3'b001,
                   PPROT_SECURE      = 3'b000,
                   PPROT_NONSECURE   = 3'b010,
                   PPROT_DATA        = 3'b000,
                   PPROT_INSTRUCTION = 3'b100;

  //HRESP
  localparam       HRESP_OKAY  = 1'b0,
                   HRESP_ERROR = 1'b1;

endpackage 