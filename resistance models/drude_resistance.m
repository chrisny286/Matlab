% Drude model
% input parameters: 
    % mobility 100-200 cm^2/Vs typ. for ZnSe
    % thickness of ZnSe:Cl
    % all length units in cm
    % dimensions: length, width, thickness (l, w, t)
% returns Ohm

function [R_drude] = drude_resistance(l, w, t, mu, n)
    e = 1.6022e-19;  % C 
    R_drude = l./(n*e*w*t*mu);
end