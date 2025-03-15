class read_busy_test extends base_test ;
  `uvm_component_utils(read_busy_test)
  
  IDLE_ahb_seq           ahb_idle_req ;
  NONSEQ_read_ahb_seq    ahb_nonseq_req ;
  ready_apb_seq          apb_resp ;
  busy_apb_seq           apb_busy ;
  
  function new(string name = "read_busy_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ahb_idle_req   = IDLE_ahb_seq        ::type_id::create("ahb_idle_req");  
    ahb_nonseq_req = NONSEQ_read_ahb_seq ::type_id::create("ahb_nonseq_req");
    apb_resp       = ready_apb_seq       ::type_id::create("apb_resp");
    apb_busy       = busy_apb_seq        ::type_id::create("apb_busy");
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    
    // Reset 
    fork 
      begin 
        repeat (4) ahb_reset_s.start(env_h.ahb_agent_h.ahb_sequencer_h);
      end
        
      begin 
        repeat (2) apb_reset_s.start(env_h.apb_agent_h.apb_sequencer_h);
      end
    join_any 
    
    // IDLE 
    fork 
      begin 
        repeat (3) ahb_idle_req.start(env_h.ahb_agent_h.ahb_sequencer_h);
      end
        
      begin 
        repeat (10) apb_resp.start(env_h.apb_agent_h.apb_sequencer_h);
        repeat ( 2) apb_busy.start(env_h.apb_agent_h.apb_sequencer_h); 
        repeat ( 5) apb_resp.start(env_h.apb_agent_h.apb_sequencer_h);
      end
    join_any
    
    // NONSEQ 
    repeat(1) begin 
    fork
      ahb_nonseq_req.start(env_h.ahb_agent_h.ahb_sequencer_h);
    join 
    end
    
    // IDLE 
    repeat(30) ahb_idle_req.start(env_h.ahb_agent_h.ahb_sequencer_h);    
    
    phase.drop_objection(this);
  endtask

endclass : read_busy_test
