classdef CollisionTypes

    properties(Constant=true)
        Min=0
        NoCollision=0
        BlockAll=1
        OverlapAll=2
        BlockAllDynamic=3
        OverlapAllDynamic=4
        IgnoreOnlyPawn=5
        OverlapOnlyPawn=6
        Pawn=7
        Spectator=8
        CharacterMesh=9
        PhysicsActor=10
        Destructible=11
        InvisibleWall=12
        InvisibleWallDynamic=13
        Trigger=14
        Ragdoll=15
        Vehicle=16
        UserInterface=17
        Max=17
    end

end