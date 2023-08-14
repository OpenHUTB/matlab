function bounds=levelThreeBounds(category)




    switch category
    case "A"
        bounds{1}=[...
        1,0.38;
        100,4;
        ];
    case "B"
        bounds{1}=[...
        1,0.2;
        100,1.9;
        ];
    case "C"
        bounds{1}=[...
        1,0.31;
        100,3.1
        ];
    end
end