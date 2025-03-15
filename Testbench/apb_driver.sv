
class apb_driver extends uvm_driver #(apb_seq_item);
  `uvm_component_utils(apb_driver)

  
  // Sequence item Declaration  
  apb_seq_item apb_driver_item ;
  
  // Config class Declaration 
  apb_cnfg apb_cnfg_h ;
  
  // Virtual Interface Declaration 
  virtual apb_intf apb_intf_h ;
  virtual apb_intf apb_driver_intf_h ;
  
  
 // Constructor  
  function new(string name = "apb_driver" ,uvm_component parent);
    super.new(name,parent);
  endfunction :new
 
   
 // Build Phase 
  function void build_phase(uvm_phase phase);    
    super.build_phase(phase);
    
    // Get Interface 
    if(!(uvm_config_db #(virtual apb_intf)::get(this,"*","apb_intf_h",apb_intf_h))) 
    `uvm_error(get_type_name(),"failed to get virtual interface inside APB Driver class") 
      
    // Get Configuartion   
    if (!uvm_config_db  #(apb_cnfg) ::get(this,"" , "apb_configuration", apb_cnfg_h ))
    `uvm_fatal(get_type_name(), "configuration not found" )  
      
  endfunction : build_phase 
      
      
 // Connect Phase 
  function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
	apb_driver_intf_h = apb_intf_h ;
  endfunction :connect_phase
           
        
  // Run Phase 
  task run_phase (uvm_phase phase);   
    super.run_phase(phase);
    forever begin    
      apb_driver_item = apb_seq_item::type_id::create("apb_driver_item");   
      seq_item_port.get_next_item(apb_driver_item) ;
      drive(apb_driver_item) ;
      seq_item_port.item_done() ;    
    end   
  endtask : run_phase 
      
      
      
 // drive task 
  virtual task drive (apb_seq_item apb_tr) ; // Drive task begin 
    
    @(posedge apb_driver_intf_h.pclk) ;  
    
    // Synchronize with Monitor
    -> apb_cnfg_h.sync_start;
    
    // Drive Reset
    apb_driver_intf_h.PRESETn <= apb_tr.PRESETn ;
    
    if(apb_driver_intf_h.PSEL) begin // PSEL check begin 
      apb_driver_intf_h.PREADY  <= apb_tr.PREADY ;
      apb_driver_intf_h.PSLVERR <= apb_tr.PSLVERR ;
      if(!apb_driver_intf_h.PENABLE)
      apb_driver_intf_h.PRDATA  <= (apb_driver_intf_h.PWRITE) ? 32'hxxxx_xxxx : apb_driver_item.PRDATA ;          
    end // PSEL check end 
    
  endtask  // Drive task end 
  
  
endclass : apb_driver
 