`timescale 1ns / 1ps

module target_select (
    input logic       clk,
    input logic       reset,
    // 모양 식별 모듈과의 signals
    input logic [3:0] hint_count,
    input logic [7:0] hint_data,
    input logic       data_done,
    input logic       frame_done
    // 출력

);

    // port 이름

    // [3:0] hint_count : 힌트의 개수   ( 이 신호가 들어오면 힌트의 개수가 확정됨)

    // [7:0] hint_data  : 힌트 데이터  모양(2 bit), 색(2 bit), 위치 (4bit) 순서대로

    //  data_done : 한 바이트가 완성 되었을때 1 tick 1이 되었다가 다시 끈다. -> hint_data 를 입력 받음

    // frame_done : 1 프레임 안에 있는 모든 모양, 색 위치를 파악 완료하면 1 tick 생성 후에 다시 0
    //              -> hint_count 를 저장 시작
    typedef enum {
        IDLE,
        DECISION
    } state_t;
    state_t c_state, n_state;


    logic [7:0] c_data_mem[0:15];
    logic [7:0] n_data_mem[0:15];

    logic [5:0] n_count_reg, c_count_reg;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            for (int i = 0; i < 16; i++) begin
                c_data_mem[i] <= 0;
            end
            c_count_reg <= 0;
            c_state <= IDLE;
        end else begin
            for (int i = 0; i < 16; i++) begin
                c_data_mem[i] <= n_data_mem[i];
            end
            c_count_reg <= n_count_reg;
            c_state <= n_state;
        end
    end

    always_comb begin
        for (int i = 0; i < 16; i++) begin
            n_data_mem[i] = c_data_mem[i];
        end
        n_count_reg = c_count_reg;
        case (c_state)
            IDLE: begin
                if (frame_done) begin
                    n_state = DECISION;
                    n_count_reg = hint_count;
                end
            end
            DECISION: begin

            end
        endcase
    end




endmodule

// port 이름

// [3:0] hint_count : 힌트의 개수   ( 이 신호가 들어오면 힌트의 개수가 확정됨)

// [7:0] hint_data  : 힌트 데이터  모양(2 bit), 색(2 bit), 위치 (4bit) 순서대로

//  data_done : 한 바이트가 완성 되었을때 1 tick 1이 되었다가 다시 끈다. -> hint_data 를 입력 받음

// frame_done : 1 프레임 안에 있는 모든 모양, 색 위치를 파악 완료하면 1 tick 생성 후에 다시 0
//              -> hint_count 를 저장 시작
