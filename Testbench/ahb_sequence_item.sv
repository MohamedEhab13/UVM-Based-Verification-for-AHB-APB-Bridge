import bridge_pkg::* ;

class ahb_seq_item extends uvm_sequence_item ;
  
  
  // Constructor 
  function new (string name = "ahb_seq_item" );
    super.new(name);
  endfunction
  
  
  // Random AHB Signals Declaration 
  rand bit                    HRESETn   ;
  rand bit                    HSEL      ;
  rand bit [HADDR_SIZE  -1:0] HADDR     ;
  rand bit [HDATA_SIZE  -1:0] HWDATA    ;
  rand bit                    HWRITE    ;
  rand bit [             2:0] HSIZE     ;
  rand bit [             2:0] HBURST    ;
  rand bit [             3:0] HPROT     ;
  rand bit [             1:0] HTRANS    ;
  rand bit                    HMASTLOCK ;
  rand bit                    HREADY    ;
 
  // Output Signals 
  logic [HDATA_SIZE  -1:0] HRDATA    ;
  logic                    HREADYOUT ;
  logic                    HRESP     ;
  
  
  
  // Functions Automation (copy, compare and print)
  `uvm_object_utils_begin(ahb_seq_item)
  `uvm_field_int (HRESETn   , UVM_DEFAULT)
  `uvm_field_int (HSEL      , UVM_DEFAULT)
  `uvm_field_int (HADDR     , UVM_DEFAULT)
  `uvm_field_int (HWDATA    , UVM_DEFAULT)
  `uvm_field_int (HWRITE    , UVM_DEFAULT)
  `uvm_field_int (HSIZE     , UVM_DEFAULT)
  `uvm_field_int (HBURST    , UVM_DEFAULT) 
  `uvm_field_int (HPROT     , UVM_DEFAULT)
  `uvm_field_int (HTRANS    , UVM_DEFAULT)
  `uvm_field_int (HMASTLOCK , UVM_DEFAULT)
  `uvm_field_int (HREADY    , UVM_DEFAULT)
  `uvm_field_int (HRDATA    , UVM_DEFAULT)
  `uvm_field_int (HREADYOUT , UVM_DEFAULT)
  `uvm_field_int (HRESP     , UVM_DEFAULT)
  `uvm_object_utils_end
  
  
  
  
  // Basic Constraints 
  constraint ahb_reset      {HRESETn dist {1:= 1000 , 0:= 1} ; } // low probabilty of reseting 
  constraint bridge_select  {HSEL dist {1:= 1000 , 0:= 1} ; } // high probabilty of selecting the bridge 
  constraint addr_range     {HADDR   inside {[32'h0:32'hfff]}; }
  constraint size_range     {HSIZE   inside {[0 : 2]} ; } // HSIZE should be equal to or less than AHB bus width
  constraint master_ready   {HREADY dist {1:= 1000 , 0:= 1} ; } // High propbabilty of READY master 
  constraint constant_lock  {HMASTLOCK == 1'b0 ; } 
  
  
  // Reset Function 
  function void Reset() ;
    HRDATA    = 32'hxxxx_xxxx ;
    HREADYOUT = 1'b1 ;
    HRESP     = OKAY ;
  endfunction 
  
  
endclass 
  
  
  
  