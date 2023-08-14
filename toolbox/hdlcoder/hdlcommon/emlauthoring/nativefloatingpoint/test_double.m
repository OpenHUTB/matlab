function test_double(N)



    test_double_special();
    test_double_random(N);
end

function test_double_random(N)
    for i=1:N
        AL=uint64(randi([0,intmax('uint32')]));
        AH=uint64(randi([0,intmax('uint32')]));
        A=bitor(bitshift(AH,32),AL);

        BL=uint64(randi([0,intmax('uint32')]));
        BH=uint64(randi([0,intmax('uint32')]));
        B=bitor(bitshift(BH,32),BL);
        test_double_pair(A,B);
        if(mod(i,1000)==0)
            disp(i);

            disp(packed_to_double(A));
            disp(packed_to_double(B));
        end
    end
end



function test_double_special()

    Vals=[double(-1);double(-inf);double(inf);double(nan);...
    double(-1);double(0);double(-0);double(1)];

    for i=1:7
        for j=1:7
            A=Vals(i);
            B=Vals(j);
            AI=double_to_packed(A);
            BI=double_to_packed(B);
            test_double_pair(AI,BI);
        end
    end
end
