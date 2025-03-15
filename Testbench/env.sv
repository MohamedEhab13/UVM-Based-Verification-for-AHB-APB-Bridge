class env extends uvm_env;
  `uvm_component_utils(env)
  
  
  ahb_agent ahb_agent_h ;
  apb_agent apb_agent_h ;
  scoreboard scoreboard_h ;
  coverage coverage_h ;
 
  
  
  // Constructor 
    function new(string name = "env" ,uvm_component parent);
         super.new(name,parent); 
    endfunction : new
              
              
  
  // Build Phase 
    function void build_phase(uvm_phase phase);
     super.build_phase(phase);     
      ahb_agent_h  = ahb_agent  ::type_id::create("ahb_agent_h" ,this);
      apb_agent_h  = apb_agent  ::type_id::create("apb_agent_h" ,this);
      scoreboard_h = scoreboard ::type_id::create("scoreboard_h",this);  
      coverage_h   = coverage   ::type_id::create("coverage_h"  ,this);     
    endfunction :build_phase    
              
  
  
    
  // Connect Phase 
    function void connect_phase (uvm_phase phase);
      super.connect_phase(phase); 
      // Connecting AHB monitor to Scoreboard and Coverage 
      ahb_agent_h.ahb_monitor_h.ahb_monitor_ap.connect(scoreboard_h.ahb_ap)   ;              
      ahb_agent_h.ahb_monitor_h.ahb_monitor_ap.connect(coverage_h.ahb_cov_ap) ;   
      
      // Connecting APB monitor to Scoreboard and Coverage 
      apb_agent_h.apb_monitor_h.apb_monitor_ap.connect(scoreboard_h.apb_ap)   ;            
      apb_agent_h.apb_monitor_h.apb_monitor_ap.connect(coverage_h.apb_cov_ap) ;  
  endfunction :connect_phase
  
  
  // Run Phase 
    task run_phase(uvm_phase phase);
      super.run_phase(phase);
    endtask : run_phase
  
endclass : env
