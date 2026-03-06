`timescale 1ns / 1ps
`include "define.h"
module target_select (
    input  logic       clk,
    input  logic       reset,
    // 모양 식별 모듈과의 signals
    input  logic [3:0] hint_count,
    input  logic [7:0] hint_data,
    input  logic       data_done,
    input  logic       frame_done,
    // 출력
    output logic [7:0] target_data
);

    // port 이름

    // [3:0] hint_count : 힌트의 개수   ( 이 신호가 들어오면 힌트의 개수가 확정됨)

    // [7:0] hint_data  : 힌트 데이터  모양(2 bit), 색(2 bit), 위치 (4bit) 순서대로

    //  data_done : 한 바이트가 완성 되었을때 1 tick 1이 되었다가 다시 끈다. -> hint_data 를 입력 받음

    // frame_done : 1 프레임 안에 있는 모든 모양, 색 위치를 파악 완료하면 1 tick 생성 후에 다시 0
    //              -> hint_count 를 저장 시작

    logic [1:0] color;
    logic [1:0] shape;
    logic [3:0] section;

    assign {shape, color, section} = hint_data;

    logic [7:0] n_score[0:14];
    logic [7:0] c_score[0:14];
    logic [7:0] c_max_score, n_max_score;

    logic [3:0] c_max_index, n_max_index;

    assign target_data = frame_done ? {4'b1111, c_max_index} : 8'bz; // frame_done 에 따라 출력 끊기를 안해도 되나? 생각

    // 데이터 및 개수 초기화
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            for (int i = 0; i < 16; i++) begin
                c_score[i] <= 0;
            end
            c_max_index <= 0;
            c_max_score <= 0;
        end else begin
            for (int i = 0; i < 16; i++) begin
                c_score[i] <= n_score[i];
            end
            c_max_index <= n_max_index;
            c_max_score <= n_max_score;
        end
    end

    // 데이터 저장 및 frame_done 발생 시 hint count 저장
    always_comb begin
        for (int i = 0; i < 16; i++) begin
            n_score[i] = c_score[i];
        end

        if (data_done) begin
            case (shape)  // 모양 색 위치에 맞는 score 을 더한다
                `SQUARE: begin
                    n_score[`SECTION_0] += 123;
                end
                `TRIANGLE: begin

                end
                `CIRCLE: begin

                end
            endcase
        end
    end

    always_comb begin  // score 최댓값 및 최댓값의 위치 저장
        n_max_index = c_max_index;
        n_max_score = c_max_score;
        for (int i = 0; i < 16; i++) begin
            if (c_max_score < c_score[i]) begin
                n_max_index = i;
                n_max_score = c_score[i];
            end
        end
    end
    // ---------------------------------------------------------------------
    // 상태 및 우선 순위 초기화
    // always_ff @(posedge clk or posedge reset) begin
    //     if (reset) begin
    //         c_state <= IDLE;
    //         c_index_count <= 0;
    //     end else begin
    //         c_state <= n_state;
    //         c_index_count <= n_index_count;
    //     end
    // end

    // always_comb begin
    //     n_state = c_state;
    //     n_index_count = c_index_count;
    //     case (c_state)
    //         IDLE: begin
    //             if (frame_done) begin
    //                 n_state = CALCULATE_TARGET;
    //             end
    //         end
    //         CALCULATE_TARGET: begin

    //         end
    //         SEND_TARGET: begin

    //         end
    //     endcase
    // end
endmodule
