function y=privatenormpdf(x,mu,sigma)









    narginchk(1,3);
    if nargin<2
        mu=0;
    end
    if nargin<3
        sigma=1;
    end


    sigma(sigma<=0)=NaN;

    try
        y=exp(-0.5*((x-mu)./sigma).^2)./(sqrt(2*pi).*sigma);
    catch %#ok<CTCH>
        error(message('SimBiology:privatenormpdf:InputSizeMismatch'));
    end
