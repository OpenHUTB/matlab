function theta=wrapToPi(theta)
%#codegen
    coder.allowpcode('plain');














%#codegen

    if any(abs(theta)>pi,'all')

        piVal=cast(pi,'like',theta);

        theta=vdynutils.wrapTo2Pi(theta+piVal)-piVal;
    end
end
