class ahb_agent extends uvm_agent ;
  `uvm_component_utils(ahb_agent)
  
  // Components
  ahb_driver ahb_driver_h ;
  ahb_monitor ahb_monitor_h ;
  ahb_sequencer ahb_sequencer_h ;
  
  
  
  // Constructor  
  function new(string name = "ahb_agent" ,uvm_component parent);
    super.new(name,parent);
  endfunction :new
  
  
  
  // Build Phase 
  function void build_phase(uvm_phase phase);  
    super.build_phase(phase);
    ahb_driver_h    = ahb_driver::type_id::create("ahb_driver_h",this);
    ahb_monitor_h   = ahb_monitor::type_id::create("ahb_monitor_h",this);
    ahb_sequencer_h = ahb_sequencer::type_id::create("ahb_sequencer_h",this); 
  endfunction : build_phase 
  
  
  
 // Connect Phase 
  function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);	  
    ahb_driver_h.seq_item_port.connect(ahb_sequencer_h.seq_item_export); // connect driver to sequencer
  endfunction :connect_phase
  
  
  
 // Run Phase 
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
  endtask : run_phase
  
  
endclass : ahb_agent 
