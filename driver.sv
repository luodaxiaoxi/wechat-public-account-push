class monitor;
task  sample_pkt();
    
    while(1) begin
        sample_cnt = 0;
        wait(bus.vld == 1);
        if(bus.pid != 0) begin
            `uvm_error();
        end
        
        mon_tr.data_queue.push_back(bus.data_out);
        mon_tr.pid_queue.push_back(bus.pid);
        if(bus.pid != 0) begin
            `uvm_error();
        end
        @mon_cb;
        while(bus.pid != 0) begin
            sample_cnt ++;
            mon_tr.data_queue.push_back(bus.data_out);
            mon_tr.pid_queue.push_back(bus.pid);
            @mon_cb;
            if(sample_cnt > xxx || sample_cnt <= xxx)
                `uvm_error();
        end

        mon_port.write(mon_tr);
        
    end


endtask //sample_pkt
endclass

  // 洗牌算法
  task shuffle;
    int temp;
    int swap_idx;
    for (int i = 0; i < N; i++) begin
      // 随机生成交换索引
      swap_idx = $urandom_range(0, N-1);

      // 交换pid[i]和pid[swap_idx]
      temp = pid[i];
      pid[i] = pid[swap_idx];
      pid[swap_idx] = temp;
    end
  endtask

  // 插入重复数,重复数字次数随机，插入重复数的位置在已有该数据的后面
  //可以配置为
  task insert_duplicates(bit[2:0] cfg_mode);
    int duplicate_count;
    int insert_position;
    int final_size = 0;

    // 遍历pid队列
    for (int i = 0; i < N; i++) begin
      // 随机决定当前数字的重复次数，范围是0到4次
      //duplicate_count = $urandom_range(0, MAX_DUPLICATES);
      case (cfg_mode)
        0: duplicate_count = $urandom_range(0, MAX_DUPLICATES); // 随机次数
        1: duplicate_count = 1;
        2: duplicate_count = 2;
        3: duplicate_count = 3;
        4: duplicate_count = 4;
      endcase

      // 插入当前数本身到final_array
      final_array[final_size] = pid[i];
      final_size++;

      // 插入重复数
      for (int j = 0; j < duplicate_count; j++) begin
        // 随机选择插入位置，在当前数字之后
        insert_position = $urandom_range(final_size - 1, final_size); // 确保在最后插入

        // 将重复数插入到随机位置，后面的元素后移
        for (int k = final_size; k > insert_position; k--) begin
          final_array[k] = final_array[k-1];
        end

        // 在插入位置放入重复的数
        final_array[insert_position] = pid[i];
        final_size++;
      end
    end
  endtask
