function TV_update = TV_Spatial_new(out_img,beta_sqrd)

% Computing numerator terms
temp_a=diff(out_img,1,2);
temp_b=diff(out_img,1,1);

T1_num=zeros(size(out_img));
T1_num(:,1:end-1,:)=temp_a;
T2_num=zeros(size(out_img));
T2_num(:,2:end,:)=temp_a;
T3_num=zeros(size(out_img));
T3_num(1:end-1,:,:)=temp_b;
T4_num=zeros(size(out_img));
T4_num(2:end,:,:)=temp_b;

% Generating imgs for computing denominator terms
xmyp_img = intshft(out_img,[-1 1]);
xmym_img = intshft(out_img,[1 1]);
xpym_img = intshft(out_img,[1 -1]);

% Computing denominator terms
T1_den = sqrt(beta_sqrd + abs(T1_num).^2 + (abs((T3_num + T4_num)/2)).^2);
T2_den = sqrt(beta_sqrd + abs(T2_num).^2 + (abs((xmyp_img - xmym_img)/2)).^2);
T3_den = sqrt(beta_sqrd + abs(T3_num).^2 + (abs((T1_num + T2_num)/2)).^2);
T4_den = sqrt(beta_sqrd + abs(T4_num).^2 + (abs((xpym_img - xmym_img)/2)).^2);

% Computing the terms
T1 = T1_num./T1_den;
T2 = T2_num./T2_den;
T3 = T3_num./T3_den;
T4 = T4_num./T4_den;

TV_update = T1-T2+T3-T4;


% To shift 3d matrix 'm' by 'sh'
function m2=intshft(m,sh)

[nx ny ~]=size(m);

m3=m;
m2=m;

k1=abs(sh(1));
k2=abs(sh(2));

if(sh(1)>0 && sh(2)>0)
    m2(k1+1:nx,k2+1:ny,:)=m(1:nx-k1,1:ny-k2,:);
end
if(sh(1)<0 && sh(2)<0)
    m2(1:nx-k1,1:ny-k2,:)=m(k1+1:nx,k2+1:ny,:);
end
if(sh(1)>0 && sh(2)<0)
    m2(k1+1:nx,1:ny-k2,:)=m(1:nx-k1,k2+1:ny,:);
end
if(sh(1)<0 && sh(2)>0)
    m2(1:nx-k1,k2+1:ny,:)=m(k1+1:nx,1:ny-k2,:);
end
if(sh(1)==0 && sh(2)==0)
    m2=m3;
end
if(sh(1)<0 && sh(2)==0)
    m2(1:nx-k1,1:ny,:)=m(k1+1:nx,1:ny,:);
end
if(sh(1)>0 && sh(2)==0)
    m2(k1+1:nx,1:ny,:)=m(1:nx-k1,1:ny,:);
end
if(sh(1)==0 && sh(2)>0)
    m2(1:nx,k2+1:ny,:)=m(1:nx,1:ny-k2,:);
end
if(sh(1)==0 && sh(2)<0)
    m2(1:nx,1:ny-k2,:)=m(1:nx,k2+1:ny,:);
end

return;
