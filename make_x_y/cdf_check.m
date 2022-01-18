
max_x = max(max([stack_sample_fr_Ca_CCW,stack_sample_fr_Ca_CW,stack_test_fr_Ca_CCW,stack_test_fr_Ca_CW]));

for neuron = kki
    x = 0:0.01:max_x;
    for i = 1:length(x)
        y_s_cw(i) = nnz(stack_sample_fr_Ca_CW(neuron,:)<x(i))/length(stack_sample_fr_Ca_CW(neuron,:));
        y_s_ccw(i) = nnz(stack_sample_fr_Ca_CCW(neuron,:)<x(i))/length(stack_sample_fr_Ca_CCW(neuron,:));
        y_t_cw_m(i) = nnz(stack_test_fr_Ca_CW_m(neuron,:)<x(i))/length(stack_test_fr_Ca_CW_m(neuron,:));    
        y_t_cw_nm(i) = nnz(stack_test_fr_Ca_CW_nm(neuron,:)<x(i))/length(stack_test_fr_Ca_CW_nm(neuron,:));
        y_t_ccw_m(i) = nnz(stack_test_fr_Ca_CCW_m(neuron,:)<x(i))/length(stack_test_fr_Ca_CCW_m(neuron,:));
        y_t_ccw_nm(i) = nnz(stack_test_fr_Ca_CCW_nm(neuron,:)<x(i))/length(stack_test_fr_Ca_CCW_nm(neuron,:));
    
    end
    figure;
    hold on
    plot(x,y_s_cw,'DisplayName','Sample CW')
    plot(x,y_t_cw_m,'DisplayName','Test CW match')
    plot(x,y_t_cw_nm,'DisplayName','Test CW nonmatch')
    plot([mean(stack_sample_fr_Ca_CW(neuron,:)),mean(stack_sample_fr_Ca_CW(neuron,:))],[0,1],'b--','DisplayName','mean sample CW')
    hold off
    grid on
    legend
    title(['neuro #',num2str(neuron)])
    xlabel('number of spikes across 1 second')
    ylabel('cdf trials')
    
    figure;
    hold on
    plot(x,y_s_ccw,'DisplayName','Sample CCW')
    plot(x,y_t_ccw_m,'DisplayName','Test CCW match')
    plot(x,y_t_ccw_nm,'DisplayName','Test CCW nonmatch')
    plot([mean(stack_sample_fr_Ca_CCW(neuron,:)),mean(stack_sample_fr_Ca_CCW(neuron,:))],[0,1],'k--','DisplayName','mean sample CCW')
    hold off
    grid on
    legend
    title(['neuro #',num2str(neuron)])
    xlabel('number of spikes across 1 second')
    ylabel('cdf trials')
    

 end