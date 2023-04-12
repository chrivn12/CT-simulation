function [ analysis ] = PSAnalysis( phantom, im, patientsize, LAT, AP, energy, exposure )
%   SEANALYSIS analyzes each vessel ROI for a single energy
%
%   Analysis analyze each vessel ROI of a single energy and
%   outputs a formatted cell array of strings, that will be written to a
%   previously initialized Excel file.
%
%   INPUTS:
%
%   phantom                       Indexed Image Phantom object, used to
%                                 get mask of vessels to analyze.
%
%
%   im                            Simulated image
%  
%   patientsize                   Small, medium, large. For calibration
%
%   LAT                           Lateral width
%
%   AP                            Anteroposterior thickness
%
%   energy                        Energy of CT Scan (kVp)
%
%   OUTPUTS:
%
%   analysis                      Cell array of formatted strings to be
%                                 inputted into Excel file
%
%
%   AUTHOR:       Shu Nie
%   REFERENCE:    SEAnalysis
%   DATE CREATED: 26-Sep-2022
%

analysis = { };

vessel_idx  = phantom.vessel_idx;
vessel_mat  = phantom.vessel_material;
vessel_mask = phantom.vessel_mask;

for i = 1 : length(vessel_mat)
    m_idx    = vessel_idx(i);
    material = vessel_mat{i};
    m_frac   = regexp(material, '(\d*\.\d+)|(\d+)','match');
    if isempty(m_frac)
        m_frac = 100;
    end
    roi_mean = mean(im(vessel_mask == m_idx));
    roi_std  = std(im(vessel_mask == m_idx));
    analysis = [analysis; sprintf('%s',patientsize), sprintf('%f',LAT),...
        sprintf('%f',AP), sprintf('%f',energy),... 
        sprintf('%f',exposure), roi_mean, roi_std, m_frac];
end




end
