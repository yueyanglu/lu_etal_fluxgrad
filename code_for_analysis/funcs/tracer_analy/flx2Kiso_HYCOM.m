function Kiso = flx2Kiso_HYCOM(dcdx_u,dcdy_v,fu,fv)
% 
% 'flx2K_HYCOM.m' calculates the instantaneous eddy diffusivity tensor 
%  and/or asscociated variables from the given large-scale tracer and eddy
%  tracer flux.
% 
%   Input:
%      cxu  [nj,ni,ndist]: zonal tracer grad on u-point 
%      cyv  [nj,ni,ndist]: meridional tracer grad on v-point 
%      fu   [nj,ni,ndist]: Zonal eddy flx 
%      fv   [nj,ni,ndist]: Meridional eddy flx
%
%   Output:
%      K    [nj,ni]: 
% 

%% check size of input

% must be 2D
if numel(size(dcdx_u)) >  3
    error('f2K function accepts 3D fields only (j-i-ndist) !!');
end

% inputs must be in the same size
if ~isequal(numel(dcdx_u),numel(dcdy_v),numel(fu),numel(fv))
    error('Size of the inputs must be the same !!!');
end

% size
[nj,ni,ndist] = size(dcdx_u);

if ndist < 2
    error('Must have at least 2 traceres !!!');
end

%% interpolate large-scale tracer gradient on v/u points
%  NO NEED for isotropic diffusivity !

% [dcdx_v, dcdy_u] = deal(NaN * zeros(nj,ni,ndist));
% 
% for idist = 1:ndist
%     
%     [cxu, cyv] = deal(dcdx_u(:,:,idist), dcdy_v(:,:,idist));
%     
%     % Find dCdx at the v- points [JDM-1,IDM-1]
%     cxv = (cxu(1:end-1,1:end-1) + cxu(1:end-1,2:end) + ...
%         cxu(2:end,2:end) + cxu(2:end,1:end-1)) / 4; % from SW, AC
%     
%     % Find dCdy at the u- points [JDM-1,IDM-1]
%     cyu = (cyv(1:end-1,1:end-1) + cyv(1:end-1,2:end)+...
%         cyv(2:end,2:end) + cyv(2:end,1:end-1)) / 4;
%     
%     % ASSIGN
%     [dcdx_v(2:end,1:end-1,idist), dcdy_u(1:end-1,2:end,idist)]...
%         = deal(cxv, cyu);
%         
% end
  

%% calc K

Kiso = NaN * zeros(nj,ni); 
% [angu,angv] = deal(NaN * zeros(nj,ni)); 

% Note this loop will miss the N and E boundaries of the NE
% corner bin.
% ~1min for one snapshot (sequel)
for j = 1:nj
    for i = 1:ni
        
        %------------------------------------ matrix of full eddy flux
        F = [squeeze(fu(j,i,:))';
            squeeze(fv(j,i,:))'];
        F = reshape(F,[2*ndist,1]); % column vec [Fx1;Fy1;Fx2;..]
        
        %------------------------------------ matrix of tracer gradient
        G = [squeeze(dcdx_u(j,i,:))';
            squeeze(dcdy_v(j,i,:))'];
        G = reshape(G,[2*ndist,1]); % column vec [Cx1;Cy1;Cx2;..]
        
        %------------------------------------ inverse: F = - G * K
        if all(~isnan(G),'all') && all(~isnan(F),'all')
            
            % ~flg_ang or  rank(G,norm(G)/1e2) == 4
            % smaller the TOL, easier to full rank
            if rank(G) == 4 % rank(G,norm(G)/1e2) == 4 or '/5e1'?
                K = - G \ F;  % K = - G \ F; or K = - pinv(G) * F
            else
                K = NaN;
            end
            
            % assign
            Kiso(j,i) = K;
            %----------------- calc angles btw trac grad
%             angu(j,i) = angle_vectors(G(1,1:2), G(3,1:2));
%             angv(j,i) = angle_vectors(G(2,3:4), G(4,3:4));
            
        end
    end
end
