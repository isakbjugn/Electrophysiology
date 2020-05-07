function power = RoundPower(power)
    % Calculates upper bound for x-value for plotting power law
    % distribution together with empirical avalanche distribution
    
    exponent = 0.5 * ceil( 2*log10(power));
    power = 10^exponent;
end % function