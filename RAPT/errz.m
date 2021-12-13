function [ FCV, FCUV, VDE, GPE, FPE, FFE ] = errz( P_REF, P_EST )
%errz 


if( length(P_EST) ~= length(P_REF) )
    error('Estimate and Reference are not the same length')
end

% 1 for Voiced, 0 for unvoiced
vuv = P_REF > 1;
% The length of reference
T   = length(P_REF);

vuv_est = ~( (P_EST < 1) | isnan(P_EST) );

FCV  = sum((vuv_est == 1) & (vuv == 0))./T;
FCUV = sum((vuv_est == 0) & (vuv == 1))./T;
VDE = FCV + FCUV;


voiced_mask = vuv_est & vuv;

NVF = sum(voiced_mask);

err = abs( (P_REF-P_EST) ./P_REF );
THRESH = 0.2;

NVM = sum(voiced_mask);
GPE = sum(err(voiced_mask)>THRESH)./NVM;

fe_sel = voiced_mask & (err<=THRESH);

PERR = ( (P_REF(fe_sel)-P_EST(fe_sel) )./P_REF(fe_sel) ).^2;
FPE  = sqrt(sum(PERR)./NVF);

ffe_sel = (~(vuv_est==vuv)) | (err>THRESH);

FFE = sum(ffe_sel)./length(ffe_sel);

end

