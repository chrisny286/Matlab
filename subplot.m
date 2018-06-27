% helper function to identify the data type
% true if 'TLM', elif: 'Areas', else: skip
function [] = add_subplot(m, n, 1, title, figlure_label, legend_options, x_fit_range, labels)
    subplot( m, n, i)     
    h = plot( fitresult, xData, yData, figlure_label );
	title(char(title));
	axis([xmin-0.1*abs(xmin) xmax+0.1*abs(xmax) -1 1]);
	axis 'auto y';
	legend( h, legend_options(1), legend_options(2), legend_options(3), legend_options(4));
	% Label axes
    xlabel= labels(1);
    ylabel= labels(2);
    grid on