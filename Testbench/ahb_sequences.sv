// Random AHB sequence 
class rand_ahb_seq extends uvm_sequence #(ahb_seq_item);
  `uvm_object_utils(rand_ahb_seq)
  
  ahb_seq_item rand_ahb_item ;
  
  function  new(string name = "rand_ahb_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    rand_ahb_item = ahb_seq_item::type_id::create("rand_ahb_item") ;
    start_item(rand_ahb_item) ; 
    assert(rand_ahb_item.randomize())           
    else
   `uvm_error(get_type_name(),"randomization failed in rand_ahb_sequence")  
    finish_item(rand_ahb_item);	 
  endtask
  
endclass: rand_ahb_seq

//-------------------------------------------------------------------------------------------------

// Reset AHB sequence 
class reset_ahb_seq extends uvm_sequence #(ahb_seq_item);
  `uvm_object_utils(reset_ahb_seq)
  
  ahb_seq_item ahb_transaction ;
  
  function  new(string name = "reset_ahb_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    ahb_transaction = ahb_seq_item::type_id::create("ahb_transaction") ;
    start_item(ahb_transaction) ; 
    assert(ahb_transaction.randomize() with {
           ahb_transaction.HTRANS == IDLE ;
           ahb_transaction.HRESETn == 0 ;})           
    else
    `uvm_error(get_type_name(),"randomization failed in reset_ahb_seq")  
    finish_item(ahb_transaction);	 
  endtask
  
endclass: reset_ahb_seq


//-------------------------------------------------------------------------------------------------

// IDLE AHB sequence 
class IDLE_ahb_seq extends uvm_sequence #(ahb_seq_item);
  `uvm_object_utils(IDLE_ahb_seq)
 
  ahb_seq_item ahb_transaction ;
  
  function  new(string name = "IDLE_ahb_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    ahb_transaction = ahb_seq_item::type_id::create("ahb_transaction") ;
    start_item(ahb_transaction) ; 
    assert(ahb_transaction.randomize() with {
           ahb_transaction.HRESETn == 1 ;
           ahb_transaction.HSEL == 1 ;
           ahb_transaction.HTRANS == IDLE ;})           
    else
      `uvm_error(get_type_name(),"randomization failed in IDLE_ahb_seq")  
    finish_item(ahb_transaction);	 
  endtask
  
endclass: IDLE_ahb_seq

//-------------------------------------------------------------------------------------------------

// IDLE write AHB sequence 
class IDLE_write_ahb_seq extends uvm_sequence #(ahb_seq_item);
  `uvm_object_utils(IDLE_write_ahb_seq)
 
  ahb_seq_item ahb_transaction ;
  
  function  new(string name = "IDLE_ahb_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    ahb_transaction = ahb_seq_item::type_id::create("ahb_transaction") ;
    start_item(ahb_transaction) ; 
    assert(ahb_transaction.randomize() with {
           ahb_transaction.HRESETn == 1 ;
           ahb_transaction.HSEL == 1 ;
           ahb_transaction.HWRITE == 1 ;
           ahb_transaction.HTRANS == IDLE ;})           
    else
      `uvm_error(get_type_name(),"randomization failed in IDLE_write_ahb_seq")  
    finish_item(ahb_transaction);	 
  endtask
  
endclass: IDLE_write_ahb_seq

//-------------------------------------------------------------------------------------------------

// NONSEQ write AHB sequence 
class NONSEQ_write_ahb_seq extends uvm_sequence #(ahb_seq_item);
  `uvm_object_utils(NONSEQ_write_ahb_seq)
  
  ahb_seq_item ahb_transaction ;
  
  function  new(string name = "NONSEQ_write_ahb_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    ahb_transaction = ahb_seq_item::type_id::create("ahb_transaction") ;
    start_item(ahb_transaction) ; 
    assert(ahb_transaction.randomize() with {
           ahb_transaction.HRESETn == 1 ;
           ahb_transaction.HSEL == 1 ;
           ahb_transaction.HWRITE == 1 ;
           ahb_transaction.HREADY == 1 ;
           ahb_transaction.HWDATA == 32'haabbccee ;
           ahb_transaction.HADDR == 32'hf00 ;
           ahb_transaction.HSIZE == 3'b010 ; // 16-bit size 
           ahb_transaction.HTRANS == NONSEQ ;})           
    else
    `uvm_error(get_type_name(),"randomization failed in NONSEQ_write_ahb_seq")  
    finish_item(ahb_transaction);	 
  endtask
  
endclass: NONSEQ_write_ahb_seq

//-------------------------------------------------------------------------------------------------


// SEQ write AHB sequence 
class SEQ_write_ahb_seq extends uvm_sequence #(ahb_seq_item);
  `uvm_object_utils(SEQ_write_ahb_seq)
  
  ahb_seq_item ahb_transaction ;
  
  function  new(string name = "SEQ_write_ahb_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    ahb_transaction = ahb_seq_item::type_id::create("ahb_transaction") ;
    start_item(ahb_transaction) ; 
    assert(ahb_transaction.randomize() with {
           ahb_transaction.HRESETn == 1 ;
           ahb_transaction.HSEL == 1 ;
           ahb_transaction.HWRITE == 1 ;
           ahb_transaction.HREADY == 1 ;
           ahb_transaction.HWDATA == 32'h778899ff ;
           ahb_transaction.HADDR == 32'h100 ;
           ahb_transaction.HSIZE == 3'b010 ; // 32-bit size 
           ahb_transaction.HTRANS == SEQ ;})           
    else
    `uvm_error(get_type_name(),"randomization failed in SEQ_write_ahb_seq")  
    finish_item(ahb_transaction);	 
  endtask
  
endclass: SEQ_write_ahb_seq

//-------------------------------------------------------------------------------------------------

// NONSEQ read AHB sequence 
class NONSEQ_read_ahb_seq extends uvm_sequence #(ahb_seq_item);
  `uvm_object_utils(NONSEQ_read_ahb_seq)
  
  ahb_seq_item ahb_transaction ;
  
  function  new(string name = "NONSEQ_read_ahb_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    ahb_transaction = ahb_seq_item::type_id::create("ahb_transaction") ;
    start_item(ahb_transaction) ; 
    assert(ahb_transaction.randomize() with {
           ahb_transaction.HRESETn == 1 ;
           ahb_transaction.HSEL    == 1 ;
           ahb_transaction.HWRITE  == 0 ; 
           ahb_transaction.HREADY  == 1 ;
           ahb_transaction.HADDR   == 32'h100 ;
           ahb_transaction.HSIZE   == 3'b010  ; // 32-bit size 
           ahb_transaction.HTRANS  == NONSEQ ;})           
    else
     `uvm_error(get_type_name(),"randomization failed in NONSEQ_read_ahb_seq")  
    finish_item(ahb_transaction);	 
  endtask
  
endclass: NONSEQ_read_ahb_seq


//-------------------------------------------------------------------------------------------------


// SEQ read AHB sequence 
class SEQ_read_ahb_seq extends uvm_sequence #(ahb_seq_item);
  `uvm_object_utils(SEQ_read_ahb_seq)
  
  ahb_seq_item ahb_transaction ;
  
  function  new(string name = "SEQ_read_ahb_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    ahb_transaction = ahb_seq_item::type_id::create("ahb_transaction") ;
    start_item(ahb_transaction) ; 
    assert(ahb_transaction.randomize() with {
           ahb_transaction.HRESETn == 1 ;
           ahb_transaction.HSEL    == 1 ;
           ahb_transaction.HWRITE  == 0 ;
           ahb_transaction.HREADY  == 1 ;
           ahb_transaction.HADDR   == 32'h333 ;
           ahb_transaction.HSIZE   == 3'b010  ; // 32-bit size 
           ahb_transaction.HTRANS  == SEQ ;})           
    else
     `uvm_error(get_type_name(),"randomization failed in SEQ_read_ahb_seq")  
    finish_item(ahb_transaction);	 
  endtask
  
endclass: SEQ_read_ahb_seq

//-------------------------------------------------------------------------------------------------


// BUSY AHB sequence 
class BUSY_ahb_seq extends uvm_sequence #(ahb_seq_item);
  `uvm_object_utils(BUSY_ahb_seq)
  
  ahb_seq_item ahb_transaction ;
  
  function  new(string name = "BUSY_ahb_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    ahb_transaction = ahb_seq_item::type_id::create("ahb_transaction") ;
    start_item(ahb_transaction) ; 
    assert(ahb_transaction.randomize() with {
           ahb_transaction.HRESETn == 1 ;
           ahb_transaction.HSEL    == 1 ;
           ahb_transaction.HREADY  == 1 ;
           ahb_transaction.HTRANS  == BUSY ;})           
    else
     `uvm_error(get_type_name(),"randomization failed in SEQ_read_ahb_seq")  
    finish_item(ahb_transaction);	 
  endtask
  
endclass: BUSY_ahb_seq

//-------------------------------------------------------------------------------------------------