function [ out ] = VImodel(in,M,param)
%VIMODEL Summary of this function goes here
%
% Model to be used M
%
n=length(in);
out=zeros(n,1);

%%
% Model to fit U(I) with U(I)=t1*ln(I/I1+1)+t2*ln(I/I2+1)
% param(i) 1: t1 2: t2 3: I1 4: I2 5: R

if M==0
  
   t1=param(1);
   t2=param(2);
   I1=param(3);
   I2=param(4);
    R=param(5);
    
    for i=1:n
        if in(i)./I1<-1
            
            if in(i)./I2 < -1
                
                out(i)=1e15+R.*in(i);
            end
        elseif in(i)./I2 < -1
            
            out(i)=t1.*log(in(i)./I1+1)+I2.*1e15+R.*in(i);
        else
            
            out(i)=t1.*log(in(i)./I1+1)+t2.*log(in(i)./I2+1)+R.*in(i);
        end
    end
   
end

%%
% Model I=a*exp(c*V)-b*exp(-d*V)
%
% param(i) 1: a 2: b 3: c 4: d
if M==1
    
    a=param(1);
    b=param(2);
    c=param(3);
    d=param(4);
    
    for i=1:n
        out(i)=a.*exp(c.*in(i))-b.*exp(-d.*in(i));
    end

end

% q*1e-17*exp(11.6045)*exp(x*a/(n*4.142))*(1-exp(-x*a/4.142))
%%
% Model U(I)=I_s1*I_s2*sinh(c*I)/(I_s1*exp(c*I)+I_s2*exp(-c*I))
%
% param(i) 1: I_s1 2: I_s2: 3: c
if M==2
    
    a=param(1);
    b=param(2);
    c=param(3);
    
    for i=1:n
        out(i)=a.*b.*sinh(c.*in(i))./(a.*exp(c.*in(i))+b.*exp(-c.*in(i)));
    end
    
end
