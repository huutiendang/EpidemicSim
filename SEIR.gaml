/**
* Name: SEIR
* Based on the internal empty template. 
* Author: tien
* Tags: 
*/


model SEIR

global { 
	//float step <- 0.01#s;
    int number_S <- 10000;
    int number_E <- 0;    
    int number_I <- 10 ;
    int number_R <- 0 ;
    int number_Q <- 0;
    
    int number_individuals<- number_S + number_E + number_I + number_Q +number_R;
    
	float beta <- 0.3 ;
	float gamma <- 19.0; // duration of infected to removed
	float D_e <- 14.0; // time between Eposed to become infectiousness
	float D_q <- 15.0; // duration of infected until Quantantine
	float D_r <- gamma - D_q; // dutation of quanrantine until removed
	//bool is_stop <- false;
	
	float R0 ;
	
	geometry shape <- square(200);
	
	init {
		create Host number: number_S {
        	is_susceptible <- true;
        	is_Exposed <- false;
        	is_infected <-  false;
        	is_quanrantine <- false;
            is_immune <-  false; 
            color <-  #green;
        }
        create Host number: number_E{
        	is_susceptible <- false;
        	is_Exposed <- true;
        	is_infected <-  false;
        	is_quanrantine <- false;
            is_immune <-  false; 
            color <-  #orange;
        }
        create Host number: number_I {
            is_susceptible <-  false;
            is_Exposed <- false;
            is_infected <-  true;
            is_quanrantine <- false;
            is_immune <-  false; 
            color <-  #red; 
       }
       create Host number: number_Q{
       		is_susceptible <- false;
       		is_Exposed <- false;
            is_infected <-  true;
            is_quanrantine <- false;
            is_immune <-  false; 
            color <-  #white; 
       }
       create Host number: number_R {
            is_susceptible <-  false;
            is_Exposed <- false;
            is_infected <-  false;
            is_quanrantine <- false;
            is_immune <-  true; 
            color <-  #blue; 
       }
       
       
       R0 <- beta/gamma;
		write "Basic Reproduction Number: "+ R0;
   }
    /*int iteration_number <- 1;
    reflex update {
        float value;
        loop times:iteration_number {
            value<-rnd(10.0);
        }
    }*/
     
    
   reflex compute_nb_infected {
   		number_I <- Host count each.is_infected;
   }
   reflex compute_nb_exposed {
   		number_E <- Host count each.is_Exposed;
   }
   reflex compute_nb_quanrantine {
   		number_Q <- Host count each.is_quanrantine;
   }
    reflex compute_nb_susceptible {
   		number_S <- Host count (each.is_susceptible);
   }
   reflex compute_nb_removed {
   		number_R <- Host count (each.is_immune);
   		
   }  
   reflex stop_simulation when: number_I = 0 and number_E = 0{
        do pause;
    }
    
}


//Grid used to discretize space 
grid sir_grid width: 100 height: 100 use_individual_shapes: true use_regular_agents: false frequency: 0{
	rgb color <- #black;
}


species Host  {
	//Booleans to represent the state of the host agent
	bool is_susceptible <- true;
	bool is_Exposed <- false;
	bool is_infected <- false;
	bool is_quanrantine <- false;
    bool is_immune <- false;
    rgb color <- #green;
    sir_grid myPlace;
    
    init {
    	//Place the agent randomly among the grid
    	myPlace <-  one_of (sir_grid as list);
    	location <- myPlace.location;
    }     
  
  	reflex become_exposed when: is_susceptible{
  		float rate <- beta*number_I/number_individuals;
    	bool results <-  flip(rate);
    	if(results){
        	is_susceptible <-  false;
        	is_Exposed <- true;
        	is_infected <-  false;
        	is_quanrantine <- false;
            is_immune <-  false;
            color <-  #orange;
  		} 
  	}
    reflex become_infected when: (is_Exposed and flip(1/D_e)){
    	//bool check <- flip(kappa);
  		//if(check){
  			is_susceptible <- false;
        	is_Exposed <- false;
        	is_infected <-  true;
        	is_quanrantine <- false;
            is_immune <-  false; 
            color <-  #red;
    }
    reflex become_quanrantine when: (is_infected and flip(1/D_q)){
    	is_susceptible <- false;
        	is_Exposed <- false;
        	is_infected <-  false;
        	is_quanrantine <- true;
            is_immune <-  false; 
            color <-  #white;
    }
    reflex become_immune when: (is_infected and flip(1/(gamma-D_q))) {
    	is_susceptible <- false;
    	is_Exposed <- false; 	
    	is_infected <- false;
    	is_quanrantine <- false;
        is_immune <- true;
        color <- #blue;
    }
    float m <- 0.01;
    reflex decrease_beta when: is_infected{
    	//beta <- beta * 0.9;
    	beta <- beta * exp(-m*number_I);   	
    }
    
    aspect basic {
        draw circle(1) color: color; 
    }
}

experiment simulation type: gui{ 
 	parameter "Number of Susceptible" var: number_S ;
 	parameter "Number of Infected" var: number_I ;	// The number of infected
    parameter "Number of Removed" var:number_R ;	// The number of removed
	parameter "Beta" var:beta; 	// The parameter Beta
	parameter "Gamma" var: gamma; // The parameter gamma
	parameter " duration of infectiousness until Quantantine" var: D_q;
	//parameter "Kappa" var: kappa;
	//float seedValue <- rnd(1.0, 10000.0);
	//float seed <- seedValue;
	//int iterator<-1;
	//int number_simulations <- 2;
	
	init{
		//create simulation;
    }
	/*reflex when: (number_I = 0){
			create simulation with: [seed::seedValue, iteration_number::2];
			//iterator <- iterator +1;
		}
	*/
	
	//reflex check_stop{
	//	if(iterator = number_simulations){
	//		is_stop <- true;
	//	}
	//}
	/* 
	reflex end_of_runs {
    int cpt <- 0;
    ask simulation{
        save ( ""+ cycle + "; " + number_S 
        	+ "; " + number_I
        	+ "; " + number_R
        	//+ " ; " + time
        )     
      	to: "results"   type: "text" rewrite: false;  
    	}
    	cpt <- cpt + 1;
    	//
    }
	
	*/
	
    
 	output { 
	    display SEIQR_display {
	        grid sir_grid lines: #black;
	        species Host aspect: basic;
	        
	    }  	
	    	
			display chart refresh: every(1#cycle) {
				chart "Susceptible-Exposed-Infected-Removed Model" type: series background: #lightgray style: exploded {
					data "susceptible" value: Host count (each.is_susceptible) color: #green;	
					data "Exposed" value: Host count (each.is_Exposed) color: #orange;	
					data "Infected" value: Host count (each.is_infected) color: #red;
					data "Quanrantine" value: Host count (each.is_quanrantine) color: #white;
					data "removed" value: Host count (each.is_immune) color: #blue;
				}
				
			}
				
			monitor "Number of susceptible" value: number_S;	      	
	      	monitor "Number of infected" value: number_I;
	      	monitor "Number of Exposed" value: number_E;
	      	monitor "Number of removed" value: number_R;
			monitor "Numer of Quanrantine" value: number_Q;
			monitor "Beta" value: beta;
	}
	
}



