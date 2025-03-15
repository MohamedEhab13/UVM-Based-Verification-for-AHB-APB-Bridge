class double_read_test extends base_test ;
  `uvm_component_utils(double_read_test)
  
  IDLE_ahb_seq            ahb_idle_req ;
  NONSEQ_read_ahb_seq     ahb_nonseq_req ;
  SEQ_read_ahb_seq        ahb_seq_req ;
  ready_apb_seq           apb_resp ;
  
  function new(string name = "double_read_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ahb_idle_req    = IDLE_ahb_seq       ::type_id::create("ahb_idle_req")  ;
    ahb_nonseq_req  = NONSEQ_read_ahb_seq::type_id::create("ahb_nonseq_req");
    ahb_seq_req     = SEQ_read_ahb_seq   ::type_id::create("ahb_seq_req")   ;
    apb_resp        = ready_apb_seq      ::type_id::create("apb_resp")      ;
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
        repeat (40) apb_resp.start(env_h.apb_agent_h.apb_sequencer_h);
      end
    join_any
    
    // NONSEQ
    ahb_nonseq_req.start(env_h.ahb_agent_h.ahb_sequencer_h);
    
    // SEQ
    ahb_seq_req.start(env_h.ahb_agent_h.ahb_sequencer_h);
   
    // IDLE
    repeat(60) ahb_idle_req.start(env_h.ahb_agent_h.ahb_sequencer_h);
      
    phase.drop_objection(this);
  endtask

endclass : double_read_test
