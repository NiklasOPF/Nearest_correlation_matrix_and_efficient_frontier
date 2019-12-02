% Niklas Forsstroem
% Final assignment script
%% plot the dataset
clf
grid on, hold on;
plot(raw_data(1:100,:)./raw_data(1,:),'linewidth',1)
%l = legend({'Barrier put option','Vanilla put option'},'Fontsize', 15);
xlabel('Days from initiation', 'Fontsize', 20)
ylabel('Stock price', 'Fontsize', 20)
title('Stock evolution from initialization', 'Fontsize', 20)
set(gca,'FontSize',20)
%% Plot 2 stocks with no overlapping data
clf
grid on, hold on;
plot(raw_data(1:100,620),'linewidth',2)
plot([nan(39,1);raw_data(40:100,167)],'linewidth',2)
l = legend({'Stock 1','Stock 2'},'Fontsize', 15);
set(gca,'FontSize',20)

xlabel('Days from initiation', 'Fontsize', 20)
ylabel('Stock price', 'Fontsize', 20)
title('Stocks without overlapping data', 'Fontsize', 20)
%%
%===========================EFFICIENT FRONTIER PART=====================================
% This part is to be used with the pre-constructed correlation matrix only
% You should use the MARKOWITZ WORKSPACE!!
% note that all vectors are row vectors due to correlation matrix

% note that the training set is using the first 101 datapoints of the
% raw_data - dataset (after normalizing)

% VARIABLE DESCRIPTIONS:

%================================================================
%% Scatter of the individual stocks
sigma = std(differences(1:100,:))';
returns = mean(differences(1:100,:))';

% for some stocks ve cant evaluate sigma and return, impute with large 
% values for sigma and 0 for return
sigma(isnan(sigma)) = 1;
returns(isnan(returns)) = 0;


% find all stocks with variance > threshold to be excluded (small: 0.1, big: 0.25)
threshold = 0.1;
include = sigma < threshold;


% plot the stocks below the threshold
%subplot(1,3,2)
hold off
scatter(sigma(include).^2, returns(include));

set(gca,'FontSize',20)
title('Small threshold', 'Fontsize', 20)
xlabel('Variance', 'Fontsize', 20)
ylabel('Return', 'Fontsize', 20)
grid on
%% Calculate the efficient frontier (using quadprog)
%==========================================================================
% Uses matlabs quadprog function to solve the mean variance problem for a 
% set of expected returns yeilding the efficient frontier. It uses the 
% correlation matrix obtained in previous steps
%==========================================================================

hold on

%fortfolio variance as a function of portfolio weights
M = diag(sigma)*training_correlations* diag(sigma);
Aeq = [returns'; not(include)'; ones(1,1516)]; % equality constraint


datapoints = 50; % number of points constituting efficient frontier
vars = zeros(datapoints,1); % vector of variances for eeach portfolio
weights = zeros(1516,datapoints); % each column is a portfolio
exp_return = linspace(0.0002,0.02,datapoints);
for i = 1:datapoints
    beq = [exp_return(i);0;1]; % equality constraint
    weights(:,i) = quadprog(M,zeros(1516,1),-eye(1516),zeros(1516,1),Aeq,beq); % find efficient portf.
    vars(i) = weights(:,i)'*M*weights(:,i); %calculate variance of the potf.
end

%% plot the efficient frontier
hold on
plot(vars, exp_return,'r','linewidth', 2)
set(gca,'FontSize',20)
xlabel('Variance', 'Fontsize', 20)
ylabel('Return', 'Fontsize', 20)
title('Efficient frontier without short selling', 'Fontsize', 20)
grid on

%% plot cumulative disteibution of portfolio weigths
%==========================================================================
% plots the empirical cdf of the portfolio weights for some given 
% index ? [1,datapoints]. this is to study the magnitude of most weights
%==========================================================================
index_to_plot = 30 %the index of interest (index ? [1,datapoints])

my_plot = cdfplot(weights(:,30));
set( my_plot, 'LineWidth', 3, 'Color', 'b');
axis([0 10e-8 0 1]);
set(gca,'FontSize',20)
xlabel('Weight magnitude (x)', 'Fontsize', 20)
ylabel('F_W(x)', 'Fontsize', 20)
title('Empirical CDF for portfolio weights', 'Fontsize', 20)
grid on


%% Out of sample testing using the portfolio strategy
% Scatter of the individual stocks
sigma = std(differences(101:200,:))';
returns = mean(differences(101:200,:))';

% for some stocks ve cant evaluate sigma and return, impute with large 
% values for sigma and 0 for return
sigma(isnan(sigma)) = 0;
returns(isnan(returns)) = 0;


% find all stocks with variance > threshold to be excluded (small: 0.1, big: 0.25)
threshold = 0.1;
include = sigma < threshold;


% plot the stocks below the threshold
%subplot(1,3,2)
hold off
scatter(sigma(include).^2, returns(include));

set(gca,'FontSize',20)
title('Small threshold', 'Fontsize', 20)
xlabel('Variance', 'Fontsize', 20)
ylabel('Return', 'Fontsize', 20)
grid on

% Use the portfolio weights from before to evaluate the risk and return of
% the different portfolios

tested_portf_returns = returns'*weights;
M_test = diag(sigma)*testing_correlations* diag(sigma);
tested_portf_var = diag(weights'*M_test*weights);
%% plot the supposedly efficient frontier
hold on
plot(tested_portf_var, tested_portf_returns,'r','linewidth', 3)
set(gca,'FontSize',20)
xlabel('Variance', 'Fontsize', 20)
ylabel('Return', 'Fontsize', 20)
title('Portfolio strategy for out of sample test', 'Fontsize', 20)
grid on