% resistance calculator, output: specific contact resistance
% input parameters: 
    % R_contact: R_c [Ohm]
    % R_specific: R_spec [Ohm*cm^2]
    % TLM_length, TLM_width = 190e-4, 75e-4; %for TLM, unit cm

function [R_specific] = specific_contact_resistance(R_c, length, width)
    pad_size = [length, width];
    area= length*width;
    R_specific = R_c * area;
end