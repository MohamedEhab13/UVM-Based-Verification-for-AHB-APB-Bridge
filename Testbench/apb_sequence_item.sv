import bridge_pkg::* ;

class apb_seq_item extends uvm_sequence_item ;
   

  
  // Constructor 
  function new (string name = "apb_seq_item" );
    super.new(name);
  endfunction
  
  
  // Random APB Signals Declaration
  rand bit                    PRESETn ;
  rand bit [PDATA_SIZE  -1:0] PRDATA  ;
  rand logic                  PREADY  ;
  rand logic                  PSLVERR ;
  
  // Output Signals 
  logic                    PSEL    ;
  logic                    PENABLE ; 
  logic [             2:0] PPROT   ;
  logic                    PWRITE  ;
  logic [PDATA_SIZE/8-1:0] PSTRB   ;
  logic [PADDR_SIZE  -1:0] PADDR   ;
  logic [PDATA_SIZE  -1:0] PWDATA  ;
  
  
  // Functions Automation (copy, compare and print)
  `uvm_object_utils_begin(apb_seq_item)
  `uvm_field_int (PRESETn   , UVM_DEFAULT)
  `uvm_field_int (PSEL      , UVM_DEFAULT)
  `uvm_field_int (PENABLE   , UVM_DEFAULT)
  `uvm_field_int (PPROT     , UVM_DEFAULT)
  `uvm_field_int (PWRITE    , UVM_DEFAULT)
  `uvm_field_int (PSTRB     , UVM_DEFAULT)
  `uvm_field_int (PADDR     , UVM_DEFAULT)
  `uvm_field_int (PWDATA    , UVM_DEFAULT)
  `uvm_field_int (PRDATA    , UVM_DEFAULT)
  `uvm_field_int (PREADY    , UVM_DEFAULT)
  `uvm_field_int (PSLVERR   , UVM_DEFAULT)
  `uvm_object_utils_end
  
  
  
  // Basic Constraints 
  constraint apb_reset   {PRESETn dist {1:= 1000 , 0:= 1} ; } // low probabilty of reseting  
  constraint data_range  {PRDATA  inside {[32'h0:32'hfff]}; }
  
 
  // Reset Function 
  function void Reset() ;
     PSEL    = 1'b0;
     PPROT   = 1'b0;
     PADDR   =  'h0;
     PWRITE  = 1'b0;
     PENABLE = 1'b0;
     PWDATA  =  'h0;
     PSTRB   =  'h0;
  endfunction 
  
  endclass 