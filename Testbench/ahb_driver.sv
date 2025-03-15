
class ahb_driver extends uvm_driver #(ahb_seq_item);
  `uvm_component_utils(ahb_driver)

  // Sequence item Declaration  
  ahb_seq_item ahb_driver_item ;
  
  // Config class Declaration 
  ahb_cnfg ahb_cnfg_h ;
  
  // Temporary storage for write data 
  logic [HDATA_SIZE  -1:0] temp_write_data ;
  logic                    write_process ;
  
  
  // Virtual Interface Declaration 
  virtual ahb_intf ahb_intf_h ;
  virtual ahb_intf ahb_driver_intf_h ;
  
  
  // Constructor  
  function new(string name = "ahb_driver" ,uvm_component parent);
    super.new(name,parent);
  endfunction :new
 
  
   
  // Build Phase 
  function void build_phase(uvm_phase phase);    
    super.build_phase(phase);
    
    // Get Interface 
    if(!(uvm_config_db #(virtual ahb_intf)::get(this,"*","ahb_intf_h",ahb_intf_h))) 
      `uvm_error(get_type_name(),"failed to get virtual interface inside AHB Driver class") 
     
    // Get Configuartion   
    if (!uvm_config_db  #(ahb_cnfg) ::get(this,"" , "ahb_configuration", ahb_cnfg_h ))
      `uvm_fatal(get_type_name(), "configuration not found" ) 
      
  endfunction : build_phase 
      
      
  // Connect Phase 
  function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
    ahb_driver_intf_h = ahb_intf_h ;
  endfunction : connect_phase
           
  
      
  // Run Phase 
  task run_phase (uvm_phase phase);   
    super.run_phase(phase);  
    forever begin    
      ahb_driver_item = ahb_seq_item::type_id::create("ahb_driver_item");   
      seq_item_port.get_next_item(ahb_driver_item) ;
      drive(ahb_driver_item) ;
      seq_item_port.item_done() ;    
    end    
  endtask : run_phase 
      
      
      
  // Drive task 
  virtual task drive (ahb_seq_item ahb_tr) ;
    
    @(posedge ahb_driver_intf_h.hclk) ;
    
    // Synchronize with Monitor
    -> ahb_cnfg_h.sync_start;
    
    // Drive Reset
    ahb_driver_intf_h.HRESETn <= ahb_tr.HRESETn ;
    
    if(ahb_driver_intf_h.HREADYOUT) begin  // HREADYOUT check begin 
      ahb_tr.HREADYOUT = ahb_driver_intf_h.HREADYOUT ;
      ahb_driver_intf_h.HTRANS <= ahb_tr.HTRANS ;
      
      if(ahb_tr.HTRANS != BUSY) begin // BUSY check begin 
        
        // Drive Address and control signals  
        ahb_driver_intf_h.HADDR <= ahb_tr.HADDR ;
        ahb_driver_intf_h.HSEL <= ahb_tr.HSEL ;
        ahb_driver_intf_h.HWRITE <= ahb_tr.HWRITE ;
        ahb_driver_intf_h.HSIZE <= ahb_tr.HSIZE ;
        ahb_driver_intf_h.HBURST <= ahb_tr.HBURST ;
        ahb_driver_intf_h.HPROT <= ahb_tr.HPROT ;
        ahb_driver_intf_h.HMASTLOCK <= ahb_tr.HMASTLOCK ;
        ahb_driver_intf_h.HREADY <= ahb_tr.HREADY ;
        
        if (ahb_tr.HWRITE == 0)
          ahb_driver_intf_h.HWDATA <= 32'hxxxx_xxxx ;
        
         
        case(ahb_tr.HTRANS) // HTRANS check begin 
          
          IDLE : begin // IDLE case begin 
            if(write_process) begin 
              ahb_driver_intf_h.HWDATA <= temp_write_data ;
              write_process <= 0 ;
            end
          end // IDLE case end 
          
          
          NONSEQ : begin // NONSEQ case begin 
            temp_write_data <= ahb_tr.HWDATA ;
            write_process <= 1 ;
          end // NONSEQ case end 
          
          
          SEQ : begin // SEQ case begin 
            temp_write_data <= ahb_tr.HWDATA ;
            ahb_driver_intf_h.HWDATA <= temp_write_data ; 
            write_process <= 1 ;
          end // SEQ case end 
          
        endcase // HTRANS check end 
        
      end // BUSY check end 
      
    end // HREADYOUT check end 
      
  endtask // Drive task end 
  
  
endclass : ahb_driver  
 