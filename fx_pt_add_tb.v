`timescale  1ns/100ps

`define SGN 2
`define WIDTH 4
`define A_INT_W 2
`define B_INT_W 3


module fx_pt_add_tb;

parameter SGN = `SGN;
parameter WIDTH = `WIDTH;
parameter A_INT_W = `A_INT_W;
parameter B_INT_W = `B_INT_W;


// input 
reg [WIDTH-1:0] a;
reg [WIDTH-1:0] b;


//output
wire [2*WIDTH:0] sum;
reg [2*WIDTH:0] result; //right
integer err; //wrong times
integer finished; //finish or not

fx_pt_add #(.SGN(SGN), 
            .WIDTH(WIDTH),
            .A_INT_W(A_INT_W),
            .B_INT_W(B_INT_W))
            inst1(.a(a),
                  .b(b),
                  .sum(sum));

//reg for exe
reg [2*WIDTH-1:0] a_temp;
reg [2*WIDTH-1:0] b_temp;
reg [2*WIDTH-1:0] sum_temp;
reg [2*WIDTH : 0] a_str;
reg [2*WIDTH : 0] b_str;
reg [2*WIDTH : 0] result_temp;
reg [WIDTH-2:0] a_small;
reg [WIDTH-2:0] b_small; 
reg signed [WIDTH + A_INT_W -1 :0] a_signed;
reg signed [WIDTH + B_INT_W -1 :0] b_signed;


reg a_sign,b_sign;
//input setting


initial 
begin: input_set_blk
    integer i; //loop time
    integer seed1;
    integer seed2;

    err = 0; finished = 0;
    seed1= 1; seed2= 2;
    
    for( i = 0; i< 10000 ;i = i+1)
    begin
        a=$random(seed1);
        b=$random(seed2);
        
            case(SGN)
            0:begin //SGN = 0;
            a_temp = {{{WIDTH-A_INT_W}{1'b0}},a,{{A_INT_W}{1'b0}}};
            b_temp = {{{WIDTH-B_INT_W}{1'b0}},b,{{B_INT_W}{1'b0}}};
            result = a_temp + b_temp;
            end
         

            1:begin  //SGN = 1;
            a_signed = {a,{{A_INT_W}{1'b0}}};
            b_signed = {b,{{B_INT_W}{1'b0}}};
            result = a_signed + b_signed ; 
            end

            default:begin //SGN !=0,1
            a_sign = a[WIDTH -1];
            b_sign = b[WIDTH -1];
            a_temp = {{{WIDTH-A_INT_W+1}{1'b0}},a[WIDTH-2:0],{{A_INT_W}{1'b0}}};
            b_temp = {{{WIDTH-B_INT_W+1}{1'b0}},b[WIDTH-2:0],{{B_INT_W}{1'b0}}};
            a_str = {a_sign,a_temp};
            b_str = {b_sign,b_temp};
            
                case({a_sign,b_sign})
                2'b00:begin
                    sum_temp = a_temp + b_temp;
                    result = {1'b0,sum_temp};
                end
                2'b01:begin // a = positive b = neg;
                    if(a_temp > b_temp) begin
                        sum_temp = a_temp - b_temp;
                        result = {1'b0, sum_temp};
                    end
                    else begin
                        sum_temp = b_temp - a_temp;
                        result_temp = {1'b1, sum_temp};
                        if(result_temp == {1'b1,{{2*WIDTH}{1'b0}}})begin
                            result = {{2*WIDTH+1}{1'b0}};
                        end
                        else begin
                            result = result_temp;
                        end
                    end
                end

                2'b10:begin //a=neg ,b=pos;
                    if(b_temp > a_temp)begin
                        sum_temp = b_temp - a_temp;
                        result = {1'b0, sum_temp};
                    end
                    else begin
                       sum_temp = a_temp - b_temp;
                       result_temp = {1'b1, sum_temp};
                        if(result_temp =={1'b1,{{2*WIDTH}{1'b0}}})begin
                            result = {{2*WIDTH+1}{1'b0}};
                        end
                        else begin
                            result = result_temp;
                        end
                    end
                end

                2'b11:begin
	    	    if((a_temp=={{2*WIDTH}{1'b0}}) && (b_temp=={{2*WIDTH}{1'b0}}))begin
			result = {{2*WIDTH+1}{1'b0}};
	    	    end
	    	    else begin
            		sum_temp = a_temp + b_temp;
            		result = {1'b1,sum_temp};
	    	    end
        	end



            endcase
	end

        endcase

    #10;

    if(sum !== result)
    begin
        err = err+ 1 ;
         $display($time,"a =%d b=%d sum=%d result=%d \n",
                            a,b,sum,result);
    end
    end
    
    #10;
        
    finished = 1;
    //$finish;
end
    





// show the output

initial
begin
    #200000;
    if(finished!==1)
        begin
        #10; $display("--------------------Error!! -------------------\n");
        #10; $display("      Your code cannot be finished!            \n");
        #10; $display("--------------------FAIL-----------------------\n");
        end
    else if(err!==0)
        begin
        #10; $display("--------------------Error!! -------------------\n");
        #10; $display("      Something's wrong with your code!        \n");
        #10; $display("      There are %3d errors! \n         ",err);
        #10; $display("--------------------FAIL-----------------------\n");
        end
    else 
        begin
        #10; $display("-----------------Congratulations!---------------\n");
        #10; $display("All data has been generated successfully!!!!!   \n");
        #10; $display("-----------------PASS---------------------------\n");
        end
    //$stop; 
    $finish;
end



initial
begin
  $fsdbDumpfile("fx_pt_add_1.fsdb");
  $fsdbDumpvars;
end








endmodule
