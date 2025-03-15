class read_write_test extends base_test ;
  `uvm_component_utils(read_write_test)
  
  IDLE_ahb_seq           ahb_idle_req ;
  NONSEQ_read_ahb_seq    ahb_nonseq_r_req ;
  NONSEQ_write_ahb_seq   ahb_nonseq_w_req ;
  ready_apb_seq          apb_resp ;
 
  
  function new(string name = "read_write_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ahb_idle_req     = IDLE_ahb_seq         ::type_id::create("ahb_idle_req");  
    ahb_nonseq_r_req = NONSEQ_read_ahb_seq  ::type_id::create("ahb_nonseq_r_req");
    ahb_nonseq_w_req = NONSEQ_write_ahb_seq ::type_id::create("ahb_nonseq_w_req");
    apb_resp         = ready_apb_seq        ::type_id::create("apb_resp");
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    
    repeat (20) begin 
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
    ahb_nonseq_r_req.start(env_h.ahb_agent_h.ahb_sequencer_h);
    
    // SEQ
    ahb_nonseq_w_req.start(env_h.ahb_agent_h.ahb_sequencer_h);
   
    // IDLE
    repeat(60) ahb_idle_req.start(env_h.ahb_agent_h.ahb_sequencer_h);

    end  
    
    phase.drop_objection(this);
  endtask

endclass : read_write_test

