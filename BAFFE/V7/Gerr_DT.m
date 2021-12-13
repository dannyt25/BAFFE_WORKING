function [ GROSS, BIG, FINE ] = Gerr_DT( P_REF, P_EST, THRESH )
%Gerr_DT 
%   The following function returns the error results of a pitch tracker
%   given estimated pitch track and the reference pitch track. The output
%   provides three types of errors. Gross Error, Big Error, and Fine Error.
%   Gross Error: Percentage of frames that deviate by more than 20%
%   Big Error  : Number of voiced frames with larger error in Fo plus the
%                number of unvoiced frames erroneously labeled as voiced.
%   Fine Error

if( length(P_EST) ~= length(P_REF) )
    error('Estimate and Reference are not the same length')
end

T   = length(P_REF);
voiced_mask = zeros(1,T);
% % Most references will be much less than 20 Hz
voiced_mask = P_REF > 20;
NVF = sum(voiced_mask);

dirac = abs( (P_REF(voiced_mask)-P_EST(voiced_mask)) )./P_REF(voiced_mask);
dirac(dirac > THRESH ) = 1;
dirac(dirac <= THRESH ) = 0;

GROSS = sum(dirac)/NVF;

BIG = 0;

FINE = sum(((P_REF(voiced_mask)-P_EST(voiced_mask))./P_REF(voiced_mask)).^2)./NVF;

end

