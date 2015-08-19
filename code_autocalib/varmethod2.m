function cost = varmethod2(brdf_plot)

% only use the top 20 rows, so update brdf_plot
brdf_plot = brdf_plot(1:20,:);

% update brdf_plot by removing empty rows
num_p = sum(brdf_plot>0,2);
brdf_plot = brdf_plot(num_p>0,:);

% compute some preliminaries
num_p  = sum(brdf_plot>0,2);
mean_x = sum(brdf_plot,2) ./ num_p;
var_x  = sum(brdf_plot.^2,2) ./ num_p - mean_x .* mean_x;

% final cost is a weighted sum of normalized variances
cost = (num_p/sum(num_p))' * (var_x ./ (mean_x.*mean_x));

% update: add the monotonicity constraint
% The basic idea is counting the number of permutations needed to sort the
% sequence.
% Nov 06, 2011 by Wu Zhe
num_row = length(mean_x);
aux_map   = (repmat(mean_x,[1 num_row]) - repmat(mean_x',[num_row 1])) > 0;
lower_mat = tril(aux_map,-1);
aux_cost = sum(lower_mat(:)) / (num_row*(num_row-1)/2);

% final cost: if too many permutations are needed, we need to remove the
% case.
if aux_cost > 0.2   cost = -1;  end

end
