function []= save_figs(a, b)
    mkdir('plots')    
    saveas(a, 'plots\curr')
    saveas(b, 'plots\Temp')
end