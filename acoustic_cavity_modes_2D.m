function acoustic_cavity_modes_2D()
    % 二维声腔参数设置（y-z平面，中心对称坐标系）
    Ly = 3.4;     % 声腔宽度 (m)
    Lz = 3.8;     % 声腔高度 (m)
    c = 340;      % 声速 (m/s)
    f_max = 300;  % 频率上限 (Hz)
    
    % 指定要绘制的模态阶数
    modes_to_plot = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,30,40,50,100];
    
    % 计算所有可能的模态组合 (ny, nz)
    n_max = 50;  % 单方向最大阶数
    [ny, nz] = meshgrid(0:n_max, 0:n_max);
    ny = ny(:);
    nz = nz(:);
    
    % 计算频率并过滤无效模态
    freqs = (c/2)*sqrt((ny/Ly).^2 + (nz/Lz).^2);
    valid_idx = ~(ny==0 & nz==0);  % 排除(0,0)模态
    freqs = freqs(valid_idx);
    ny = ny(valid_idx);
    nz = nz(valid_idx);
    
    % 按频率排序并选择小于f_max的模态
    [freqs_sorted, sort_idx] = sort(freqs);
    ny_sorted = ny(sort_idx); 
    nz_sorted = nz(sort_idx);
    
    % 筛选小于频率上限的模态
    valid_freqs = freqs_sorted <= f_max;
    freqs_filtered = freqs_sorted(valid_freqs);
    ny_filtered = ny_sorted(valid_freqs);
    nz_filtered = nz_sorted(valid_freqs);
    mode_numbers = 1:length(freqs_filtered);
    
    % 输出结果
    fprintf('频率上限: %.1f Hz\n', f_max);
    fprintf('小于上限的模态总数: %d\n\n', length(freqs_filtered));
    fprintf('%-10s %-8s %-8s %-12s\n', '模态序号', 'ny', 'nz', 'Freq(Hz)');
    fprintf('--------------------------------------------\n');
    for i = 1:length(freqs_filtered)
        fprintf('%-10d %-8d %-8d %-8.2f\n', ...
                mode_numbers(i), ny_filtered(i), nz_filtered(i), freqs_filtered(i));
    end
    
    % =====================
    % 二维网格设置（中心对称坐标系）
    Ny = 100; Nz = 100;  % 网格分辨率
    y = linspace(-Ly/2, Ly/2, Ny);   % y坐标从-Ly/2到Ly/2
    z = linspace(-Lz/2, Lz/2, Nz);   % z坐标从-Lz/2到Lz/2
    [Y, Z] = meshgrid(y, z);
    
    % =====================
    % 绘制二维模态振型
    for idx = 1:length(modes_to_plot)
        m = modes_to_plot(idx);
        if m > length(freqs_filtered)
            fprintf('警告: %d阶模态不存在（超出频率上限范围）\n', m);
            continue;
        end
        
        % 计算二维声压分布（注意坐标平移到[0,Ly],[0,Lz]）
        % 这样和SBFEM的中心对称坐标系一致
        P = cos(ny_filtered(m)*pi*(Y+Ly/2)/Ly) .* ...
            cos(nz_filtered(m)*pi*(Z+Lz/2)/Lz);
        
        % 创建二维云图
        figure('Name', sprintf('Mode %d: (%d,%d) - %.2f Hz', ...
              m, ny_filtered(m), nz_filtered(m), freqs_filtered(m)), ...
              'Position', [100, 100, 800, 600]);
        
        % 绘制二维声压云图
        surf(Y, Z, P, 'EdgeColor', 'none');
        view(2);  % 俯视图
        axis equal tight;
        colormap jet;
        colorbar;
        caxis([-1, 1]);  % 固定颜色范围
        
        % 设置坐标轴标签和范围（中心对称）
        xlim([-Ly/2, Ly/2]);
        ylim([-Lz/2, Lz/2]);
        title(sprintf('Mode %d: (%d,%d) - %.2f Hz', ...
              m, ny_filtered(m), nz_filtered(m), freqs_filtered(m)));
        xlabel('y (m)'); 
        ylabel('z (m)');
        % 添加等高线（可选）
        hold on;
        contour(Y, Z, P, 5, 'k', 'LineWidth', 0.5);
        hold off;
        
        % 保存图像
        saveas(gcf, sprintf('2D_mode_%d.png', m));
    end
end