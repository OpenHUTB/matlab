function test_nfp_single(N)



    test_float_special();
    test_float_random(N);
end

function test_float_random(N)
    for i=1:N
        A=typecast(randi([intmin,intmax],'int32'),'uint32');
        B=typecast(randi([intmin,intmax],'int32'),'uint32');
        test_pair(A,B);
        if(mod(i,1000000)==0)
            disp(i);
        end
    end
end



function test_float_special()

    Vals=[single(-inf);single(inf);single(nan);...
    single(-1);single(0);single(-0);single(1)];

    for i=1:7
        for j=1:7
            A=Vals(i);
            B=Vals(j);
            AI=single_to_packed(A);
            BI=single_to_packed(B);
            test_pair(AI,BI);
        end
    end
end
