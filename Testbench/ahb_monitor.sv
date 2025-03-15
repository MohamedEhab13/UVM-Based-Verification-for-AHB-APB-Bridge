class ahb_monitor extends uvm_monitor;
  `uvm_component_utils(ahb_monitor)


  // Sequence item Declaration  
  ahb_seq_item ahb_monitor_item ;
  
  // Config class Declaration 
  ahb_cnfg ahb_cnfg_h ;
  
  // Virtual Interface Declaration 
  virtual ahb_intf ahb_intf_h ;
  virtual ahb_intf ahb_monitor_intf_h ;
  
  
  // Port to send transactions to the scoreboard
  uvm_analysis_port # (ahb_seq_item) ahb_monitor_ap;


  // Constructor  
  function new(string name = "ahb_monitor" ,uvm_component parent);
    super.new(name,parent);
  endfunction :new
 
    
  // Build Phase 
  function void build_phase(uvm_phase phase);    
    super.build_phase(phase);
    
    // Get Interface 
    if(!(uvm_config_db #(virtual ahb_intf)::get(this,"*","ahb_intf_h",ahb_intf_h))) 
    `uvm_error(get_type_name(),"failed to get virtual interface inside AHB Monitor class")    
    
    // Get Configuartion  
    if (!uvm_config_db  #(ahb_cnfg) ::get(this,"" , "ahb_configuration", ahb_cnfg_h ))
    `uvm_fatal(get_type_name(), "configuration not found" )
      
    // Create AHB analysis port 
    ahb_monitor_ap  = new("ahb_monitor_ap",this);  
      
  endfunction : build_phase 
      
      
  // Connect Phase 
  function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
	 ahb_monitor_intf_h = ahb_intf_h ;
  endfunction : connect_phase



  // Run Phase 
  task  run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    forever begin 
      
      // Synchronize with Driver 
      wait (ahb_cnfg_h.sync_start.triggered);
      
      ahb_monitor_item = ahb_seq_item::type_id::create("ahb_monitor_item"); 
      
      // Sample AHB Interface Signals 
      @(posedge ahb_monitor_intf_h.hclk)  
      ahb_monitor_item.HRESETn   = ahb_monitor_intf_h.HRESETn ;
      ahb_monitor_item.HSEL      = ahb_monitor_intf_h.HSEL   ;
      ahb_monitor_item.HADDR     = ahb_monitor_intf_h.HADDR  ;
      ahb_monitor_item.HWDATA    = ahb_monitor_intf_h.HWDATA ;
      ahb_monitor_item.HRDATA    = ahb_monitor_intf_h.HRDATA ;
      ahb_monitor_item.HWRITE    = ahb_monitor_intf_h.HWRITE ;
      ahb_monitor_item.HSIZE     = ahb_monitor_intf_h.HSIZE  ;
      ahb_monitor_item.HBURST    = ahb_monitor_intf_h.HBURST ;
      ahb_monitor_item.HPROT     = ahb_monitor_intf_h.HPROT  ;  
      ahb_monitor_item.HTRANS    = ahb_monitor_intf_h.HTRANS ;
      ahb_monitor_item.HREADYOUT = ahb_monitor_intf_h.HREADYOUT ;
      ahb_monitor_item.HREADY    = ahb_monitor_intf_h.HREADY ;
      ahb_monitor_item.HRESP     = ahb_monitor_intf_h.HRESP ;
      
      // Call AHB write function in scoreboard 
      ahb_monitor_ap.write(ahb_monitor_item); 
        
    end // forever block 
      
  endtask : run_phase 
        
 endclass : ahb_monitor
    
