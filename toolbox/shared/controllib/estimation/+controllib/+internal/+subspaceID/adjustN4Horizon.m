function [auxord,maxsize,nrr] = ...
   adjustN4Horizon(n,auxord,maxsize,Ncap,ny,nu,dkx,OrdSel)
% Adjust N4Horizon based on data size and whether order will be searched
% for.

% Copyright 1986-2017 The MathWorks, Inc.

kest = dkx(2);
if Ncap <= (ceil(n/ny)+1)*(1+ny+nu) + (1+nu+ny)*ceil((n-ny+1)/(nu+ny))
   error(message('Controllib:estimation:tooFewSamples'))
end

test = Ncap -(ny+1)*auxord(1)-nu*auxord(1)-ny*auxord(2)-nu*auxord(3)...
   -max(auxord([2 3]));
if test<0
   auxord([2 3]) = min(auxord([2 3]),[2*n 2*n]);
end
test = Ncap -(ny+1)*auxord(1)-nu*auxord(1)-ny*auxord(2)-nu*auxord(3)...
   -max(auxord([2 3]));
if test <0 % then auxord needs to be reduced
   count = 1;
   maxc = sum(auxord);
   auxordorig = auxord;
   while test <0 && count<maxc
      auxord = auxord - 1;
      % auxord(1) = max(auxord(1),ceil(1.5*n));%ceil(n/ny)+1);%%LL
      auxord(1) = max(auxord(1),ceil(n/ny)+1);%%LL
      
      auxord([2 3]) = max(auxord([2 3]),ceil((n-ny+1)/(nu+ny))*ones(1,2));
      auxord([2 3]) = max(auxord([2 3]),[0 0]);
      auxord([2 3]) = min(auxord([2 3]),auxordorig([2 3]));
      test = Ncap -(ny+1)*auxord(1)-nu*auxord(1)-ny*auxord(2)-nu*auxord(3)...
         -max(auxord([2 3]));
      count = count+1;
   end
end
if auxord(1)<ceil(n/ny)+1
   auxord(1) = ceil(n/ny)+1;
end

if nu*auxord(3)+ny*auxord(2)+ny<=n && kest
   newa = ceil((n-ny+1)/(nu+ny));
   auxord([2,3]) = [newa,newa];
end

if OrdSel && (ny*auxord(2)+nu*auxord(3))<n
   auxord(3) = ceil((n-ny*auxord(2))/nu);
end

nrr = sum(auxord([1 2]))*ny+sum(auxord([1 3]))*nu;%2*i*(l+m);
if nrr*1.2*nrr>maxsize
   maxsize = ceil(nrr*1.2*nrr);
end
