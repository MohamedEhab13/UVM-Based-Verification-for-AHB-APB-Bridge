interface ahb_intf (input logic hclk) ; 
  
  import bridge_pkg::* ;
  
  // AHB Interface signals 
  logic                         HRESETn;
  logic                         HSEL;
  logic      [HADDR_SIZE  -1:0] HADDR;
  logic      [HDATA_SIZE  -1:0] HWDATA;
  logic      [HDATA_SIZE  -1:0] HRDATA;
  logic                         HWRITE;
  logic      [             2:0] HSIZE;
  logic      [             2:0] HBURST;
  logic      [             3:0] HPROT;
  logic      [             1:0] HTRANS;
  logic                         HMASTLOCK;
  logic                         HREADYOUT;
  logic                         HREADY;
  logic                         HRESP;

    
    
endinterface   
  
  
  