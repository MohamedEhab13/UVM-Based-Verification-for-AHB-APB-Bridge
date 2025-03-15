interface apb_intf (input logic pclk) ;
  
  import bridge_pkg::* ;
  
  // APB Interface signals 
  logic                    PRESETn  ;
  logic                    PSEL    ;
  logic                    PENABLE ;
  logic [             2:0] PPROT   ;
  logic                    PWRITE  ;
  logic [PDATA_SIZE/8-1:0] PSTRB   ;
  logic [PADDR_SIZE  -1:0] PADDR   ;
  logic [PDATA_SIZE  -1:0] PWDATA  ;
  logic [PDATA_SIZE  -1:0] PRDATA  ;
  logic                    PREADY  ;
  logic                    PSLVERR ;
  
       
endinterface