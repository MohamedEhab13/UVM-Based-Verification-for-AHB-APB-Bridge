 class base_test extends uvm_test ;
  `uvm_component_utils(base_test)

  env env_h ;
   
  ahb_cnfg ahb_cnfg_h ;
  apb_cnfg apb_cnfg_h ;
   
  reset_ahb_seq  ahb_reset_s  ;
  reset_apb_seq  apb_reset_s  ;

  // Constructor 
  function new(string name = "base_test" ,uvm_component parent);
    super.new(name,parent);
  endfunction :new

  // Build Phase 
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env_h = env::type_id::create("env_h",this);
    
    ahb_cnfg_h = ahb_cnfg::type_id::create("ahb_cnfg_h");
    apb_cnfg_h = apb_cnfg::type_id::create("apb_cnfg_h");
    
    ahb_reset_s = reset_ahb_seq::type_id::create("ahb_reset_s");
    apb_reset_s = reset_apb_seq::type_id::create("apb_reset_s");
    
    uvm_config_db #(ahb_cnfg)::set(this, "*" , "ahb_configuration" , ahb_cnfg_h);
    uvm_config_db #(apb_cnfg)::set(this, "*" , "apb_configuration" , apb_cnfg_h);
  endfunction : build_phase 

endclass :base_test

//-------------------------------------------------------------------------------


class single_write_test extends base_test ;
  `uvm_component_utils(single_write_test)
  
  IDLE_ahb_seq            ahb_idle_req ;
  IDLE_write_ahb_seq      ahb_idle_write_req ;
  NONSEQ_write_ahb_seq    ahb_nonseq_req ;
  ready_apb_seq      apb_resp ;
  
  function new(string name = "single_write_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ahb_idle_req       = IDLE_ahb_seq         ::type_id::create("ahb_idle_req");
    ahb_idle_write_req = IDLE_write_ahb_seq   ::type_id::create("ahb_idle_write_req");
    ahb_nonseq_req     = NONSEQ_write_ahb_seq ::type_id::create("ahb_nonseq_req");
    apb_resp           = ready_apb_seq        ::type_id::create("apb_resp");
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
        repeat (30) apb_resp.start(env_h.apb_agent_h.apb_sequencer_h);
      end
    join_any
    
    // NONSEQ 
    ahb_nonseq_req.start(env_h.ahb_agent_h.ahb_sequencer_h);
    
    
    // IDLE 
    repeat( 1) ahb_idle_write_req.start(env_h.ahb_agent_h.ahb_sequencer_h);
    repeat(30) ahb_idle_req.start(env_h.ahb_agent_h.ahb_sequencer_h); 
    
    
    
    phase.drop_objection(this);
  endtask

endclass : single_write_test

//------------------------------------------------------------------------------------------------------------


class double_write_test extends base_test ;
  `uvm_component_utils(double_write_test)
  
  IDLE_ahb_seq            ahb_idle_req ;
  IDLE_write_ahb_seq      ahb_idle_write_req ;
  NONSEQ_write_ahb_seq    ahb_nonseq_req ;
  SEQ_write_ahb_seq       ahb_seq_req ;
  ready_apb_seq           apb_resp ;
  
  function new(string name = "double_write_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ahb_idle_req       = IDLE_ahb_seq         ::type_id::create("ahb_idle_req");
    ahb_idle_write_req = IDLE_write_ahb_seq   ::type_id::create("ahb_idle_write_req");
    ahb_nonseq_req     = NONSEQ_write_ahb_seq ::type_id::create("ahb_nonseq_req");
    ahb_seq_req        = SEQ_write_ahb_seq    ::type_id::create("ahb_seq_req");
    apb_resp           = ready_apb_seq        ::type_id::create("apb_resp");
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
    repeat( 1) ahb_idle_write_req.start(env_h.ahb_agent_h.ahb_sequencer_h);
    repeat(60) ahb_idle_req.start(env_h.ahb_agent_h.ahb_sequencer_h);
      
    phase.drop_objection(this);
  endtask

endclass : double_write_test

//--------------------------------------------------------------------------------------------------

class write_busy_test extends base_test ;
  `uvm_component_utils(write_busy_test)
  
  IDLE_ahb_seq            ahb_idle_req ;
  IDLE_write_ahb_seq      ahb_idle_write_req ;
  NONSEQ_write_ahb_seq    ahb_nonseq_req ;
  ready_apb_seq           apb_resp ;
  busy_apb_seq            apb_busy ;
  
  function new(string name = "write_busy_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ahb_idle_req       = IDLE_ahb_seq         ::type_id::create("ahb_idle_req");  
    ahb_idle_write_req = IDLE_write_ahb_seq   ::type_id::create("ahb_idle_write_req");
    ahb_nonseq_req     = NONSEQ_write_ahb_seq ::type_id::create("ahb_nonseq_req");
    apb_resp           = ready_apb_seq        ::type_id::create("apb_resp");
    apb_busy           = busy_apb_seq         ::type_id::create("apb_busy");
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
    repeat( 1) ahb_idle_write_req.start(env_h.ahb_agent_h.ahb_sequencer_h);
    repeat(30) ahb_idle_req.start(env_h.ahb_agent_h.ahb_sequencer_h);    
    
    phase.drop_objection(this);
  endtask

endclass : write_busy_test

//---------------------------------------------------------------------------------------------------

class single_read_test extends base_test ;
  `uvm_component_utils(single_read_test)
  
  IDLE_ahb_seq            ahb_idle_req   ;
  NONSEQ_read_ahb_seq     ahb_nonseq_req ;
  ready_apb_seq           apb_resp       ;
  
  function new(string name = "single_read_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ahb_idle_req    = IDLE_ahb_seq        ::type_id::create("ahb_idle_req");
    ahb_nonseq_req  = NONSEQ_read_ahb_seq ::type_id::create("ahb_nonseq_req");
    apb_resp        = ready_apb_seq       ::type_id::create("apb_resp");
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    
    // Reset 
    fork 
      begin 
        repeat (4)ahb_reset_s.start(env_h.ahb_agent_h.ahb_sequencer_h);
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
        repeat (30) apb_resp.start(env_h.apb_agent_h.apb_sequencer_h);
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

endclass : single_read_test


//-----------------------------------------------------------------------------------------------------

class double_read_test extends base_test ;
  `uvm_component_utils(double_read_test)
  
  IDLE_ahb_seq            ahb_idle_req   ;
  NONSEQ_read_ahb_seq     ahb_nonseq_req ;
  SEQ_read_ahb_seq        ahb_seq_req    ;
  ready_apb_seq           apb_resp       ;
  
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

//------------------------------------------------------------------------------------------------

class read_busy_test extends base_test ;
  `uvm_component_utils(read_busy_test)
  
  IDLE_ahb_seq           ahb_idle_req   ;
  NONSEQ_read_ahb_seq    ahb_nonseq_req ;
  ready_apb_seq          apb_resp       ;
  busy_apb_seq           apb_busy       ;
  
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

//---------------------------------------------------------------------------------------------------

class read_write_test extends base_test ;
  `uvm_component_utils(read_write_test)
  
  IDLE_ahb_seq           ahb_idle_req   ;
  NONSEQ_read_ahb_seq    ahb_nonseq_r_req ;
  NONSEQ_write_ahb_seq   ahb_nonseq_w_req    ;
  ready_apb_seq     apb_resp       ;
 
  
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
      
    phase.drop_objection(this);
  endtask

endclass : read_write_test

//----------------------------------------------------------------------------------------------------------------

class write_error_test extends base_test ;
  `uvm_component_utils(write_error_test)
  
  IDLE_ahb_seq           ahb_idle_req ;
  NONSEQ_write_ahb_seq   ahb_nonseq_req ;
  ready_apb_seq          apb_resp ;
  err_apb_seq            apb_err ;
 
  
  function new(string name = "write_error_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ahb_idle_req     = IDLE_ahb_seq         ::type_id::create("ahb_idle_req");  
    ahb_nonseq_req   = NONSEQ_write_ahb_seq ::type_id::create("ahb_nonseq_req");
    apb_resp         = ready_apb_seq        ::type_id::create("apb_resp");
    apb_err          = err_apb_seq          ::type_id::create("apb_err");
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
        repeat ( 1) apb_err.start(env_h.apb_agent_h.apb_sequencer_h); 
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
    
    fork 
      begin 
        repeat (3) ahb_idle_req.start(env_h.ahb_agent_h.ahb_sequencer_h);
      end
        
      begin 
        repeat (30) apb_resp.start(env_h.apb_agent_h.apb_sequencer_h);
      end
    join_any
    
    // NONSEQ 
    ahb_nonseq_req.start(env_h.ahb_agent_h.ahb_sequencer_h);
    
    
    // IDLE 
    repeat(30) ahb_idle_req.start(env_h.ahb_agent_h.ahb_sequencer_h);
    
    phase.drop_objection(this);
  endtask

endclass : write_error_test

//----------------------------------------------------------------------------------------------------------------

class read_error_test extends base_test ;
  `uvm_component_utils(read_error_test)
  
  IDLE_ahb_seq           ahb_idle_req ;
  NONSEQ_read_ahb_seq    ahb_nonseq_req ;
  ready_apb_seq          apb_resp ;
  err_apb_seq            apb_err ;
 
  
  function new(string name = "read_error_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ahb_idle_req     = IDLE_ahb_seq         ::type_id::create("ahb_idle_req");  
    ahb_nonseq_req   = NONSEQ_read_ahb_seq  ::type_id::create("ahb_nonseq_req");
    apb_resp         = ready_apb_seq        ::type_id::create("apb_resp");
    apb_err          = err_apb_seq          ::type_id::create("apb_err");
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
        repeat ( 1) apb_err.start(env_h.apb_agent_h.apb_sequencer_h); 
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
    
    fork 
      begin 
        repeat (3) ahb_idle_req.start(env_h.ahb_agent_h.ahb_sequencer_h);
      end
        
      begin 
        repeat (30) apb_resp.start(env_h.apb_agent_h.apb_sequencer_h);
      end
    join_any
    
    // NONSEQ 
    ahb_nonseq_req.start(env_h.ahb_agent_h.ahb_sequencer_h);
    
    
    // IDLE 
    repeat(30) ahb_idle_req.start(env_h.ahb_agent_h.ahb_sequencer_h);
    
    phase.drop_objection(this);
  endtask

endclass : read_error_test

//----------------------------------------------------------------------------------------------------------------



