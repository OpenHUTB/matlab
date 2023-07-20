function animate(h)

















    narginchk(1,1);

    for i=1:length(h)
        h(i).mIdeModule.Animate();
    end

