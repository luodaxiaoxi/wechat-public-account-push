module controlled_shuffle_with_duplicates;
  // 参数设置
  parameter int N = 32768;                   // 0到2的15次方，共32768个数
  parameter int DUPLICATE_COUNT = 100;       // 要插入的重复数字数量
  parameter real PROB_SMALL_SHIFT = 0.95;    // 95%的概率进行小幅偏移
  parameter real PROB_MEDIUM_SHIFT = 0.04;   // 4%的概率进行中等偏移
  parameter real PROB_LARGE_SHIFT = 0.01;    // 1%的概率进行大幅偏移
  parameter int MAX_SMALL_SHIFT = 3;         // 小幅偏移范围
  parameter int MAX_MEDIUM_SHIFT = 19;       // 中等偏移范围

  // 数组和随机数
  int numbers [0:N-1];     // 数组存储从0到32767的数
  real rand_val;           // 随机数

  // 初始块：初始化数组并调用shuffle过程
  initial begin
    // 初始化数组
    for (int i = 0; i < N; i++) begin
      numbers[i] = i;
    end

    // 打印初始化的部分数组
    $display("Initial Array (first 16 elements): %p", numbers[0:15]);
    
    // 进行控制随机洗牌
    controlled_shuffle();

    // 打印洗牌后的部分数组
    $display("Shuffled Array (first 16 elements): %p", numbers[0:15]);

    // 插入随机重复数字
    insert_duplicates();

    // 打印插入重复数字后的部分数组
    $display("Array with Duplicates (first 16 elements): %p", numbers[0:15]);
  end

  // 洗牌算法
  task controlled_shuffle;
    int shift_range [$];  // 动态数组存储偏移范围
    int swap_idx;         // 用于存储随机选择的交换索引
    int temp;
    
    for (int i = 0; i < N; i++) begin
      rand_val = $urandom_range(0, 1000) / 1000.0;  // 生成[0, 1]之间的随机数
      
      // 小幅偏移（95%概率）
      if (rand_val < PROB_SMALL_SHIFT) begin
        shift_range.delete();
        for (int j = max(0, i - MAX_SMALL_SHIFT); j <= min(N-1, i + MAX_SMALL_SHIFT); j++) begin
          shift_range.push_back(j);
        end
      end
      // 中等偏移（4%概率）
      else if (rand_val < PROB_SMALL_SHIFT + PROB_MEDIUM_SHIFT) begin
        shift_range.delete();
        for (int j = max(0, i - MAX_MEDIUM_SHIFT); j < i - MAX_SMALL_SHIFT; j++) begin
          shift_range.push_back(j);
        end
        for (int j = i + MAX_SMALL_SHIFT + 1; j <= min(N-1, i + MAX_MEDIUM_SHIFT); j++) begin
          shift_range.push_back(j);
        end
      end
      // 大幅偏移（1%概率）
      else begin
        shift_range.delete();
        for (int j = 0; j < max(0, i - MAX_MEDIUM_SHIFT); j++) begin
          shift_range.push_back(j);
        end
        for (int j = min(N-1, i + MAX_MEDIUM_SHIFT + 1); j <= N-1; j++) begin
          shift_range.push_back(j);
        end
      end
      
      // 执行交换
      if (shift_range.size() > 0) begin
        swap_idx = shift_range[$urandom_range(0, shift_range.size()-1)];
        // 交换numbers[i]和numbers[swap_idx]
        temp = numbers[i];
        numbers[i] = numbers[swap_idx];
        numbers[swap_idx] = temp;
      end
    end
  endtask

  // 插入重复数字
  task insert_duplicates;
    int duplicate_values [0:DUPLICATE_COUNT-1];  // 用于存储要重复的值
    int insert_positions [$];                    // 用于存储插入位置

    // 随机选择 DUPLICATE_COUNT 个要重复的数字
    for (int i = 0; i < DUPLICATE_COUNT; i++) begin
      duplicate_values[i] = numbers[$urandom_range(0, N-1)];
    end

    // 随机选择插入位置
    for (int i = 0; i < DUPLICATE_COUNT; i++) begin
      insert_positions.push_back($urandom_range(0, N-1));
    end

    // 扩展数组并插入重复数字
    for (int i = 0; i < DUPLICATE_COUNT; i++) begin
      int insert_pos = insert_positions[i];
      // 向数组中插入重复数字
      for (int j = N-1; j > insert_pos; j--) begin
        numbers[j] = numbers[j-1];  // 向后移动元素
      end
      numbers[insert_pos] = duplicate_values[i];  // 插入重复值
    end
  endtask

  function int max(int a,int b);
    if(a>b)
      return a;
    else 
      return b;
  endfunction

  function int min(int a,int b);
    if(a<b)
      return a;
    else 
      return b;
  endfunction
endmodule