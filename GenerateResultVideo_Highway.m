FrameSize1 = DBVidReadObj.Height;
FrameSize2 = DBVidReadObj.Width;
load HighwayMap;
Map=insertShape(WarpMap,'Line',reshape(ScaledMapPoints',[1,2*DBFramesNumber]),'Color','r','LineWidth',4);

v = VideoWriter('Result_Highway.avi');
v.FrameRate=20;
open(v);
%figure;
for RTFramecounter=1:RTNumberOfFrames
    RTFrame=read(RTVidReadObj,RTFramecounter);
    if CurrentImage(RTFramecounter,1)==0
        DBFrame=zeros(FrameSize1,FrameSize2,3,'uint8');
    else
        DBFrame=read(DBVidReadObj,CurrentImage(RTFramecounter,1));
    end
    CompinedVideoFrame=[RTFrame;DBFrame];
    CompinedVideoFrameSize1=size(CompinedVideoFrame,1);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Map=insertShape(Map,'FilledCircle',[ScaledMapPoints(CurrentImage(RTFramecounter),:),2],'Color','y');
    ModifiedMap=insertShape(Map,'Circle',[ScaledMapPoints(CurrentImage(RTFramecounter),:),20],'Color','y','LineWidth',6);
    ModifiedMap=insertMarker(ModifiedMap,ScaledMapPoints(CurrentImage(RTFramecounter),:),'*','color','y','size',15);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    CompleteFrame=zeros(CompinedVideoFrameSize1+395,FrameSize2,3,'uint8');
    ModifiedMap=imresize(ModifiedMap,[395,854]);
    MapSize1=size(ModifiedMap,1);MapSize2=size(ModifiedMap,2);
    CompleteFrame(1:CompinedVideoFrameSize1,:,:)=CompinedVideoFrame;
    CompleteFrame(CompinedVideoFrameSize1+1:CompinedVideoFrameSize1+MapSize1,FrameSize2-MapSize2+1:FrameSize2,:)=ModifiedMap;%(29:494,88:954,:);
    
    CompleteFrame = insertText(CompleteFrame, [24 545], strcat('Cycle number: ',num2str(RTFramecounter)),'FontSize',38,'BoxColor','blue','BoxOpacity',0.4,'TextColor','white');
    CompleteFrame = insertText(CompleteFrame, [1 783], 'Top frame: Real-time query frame.                                                             ','FontSize',32,'BoxColor','blue','BoxOpacity',0.4,'TextColor','white');
    CompleteFrame = insertText(CompleteFrame, [1 826], 'Bottom frame: Nearest database frame to the estimated location.              ','FontSize',32,'BoxColor','blue','BoxOpacity',0.4,'TextColor','white');
    CompleteFrame = insertText(CompleteFrame, [1 869], 'Map: Estimated vehicle trajectory (Yellow), roads covered in database (red)','FontSize',32,'BoxColor','blue','BoxOpacity',0.4,'TextColor','white');

    if CorrectLocalization(RTFramecounter)==1
        CompleteFrame=insertText(CompleteFrame, [24 645], 'Correctly estimated location','FontSize',68,'BoxColor','green','BoxOpacity',0.4,'TextColor','white');
    else
        CompleteFrame=insertText(CompleteFrame, [24 645], 'Wrong location','FontSize',68,'BoxColor','red','BoxOpacity',0.4,'TextColor','white');
    end
    %imshow(CompleteFrame);
    %drawnow;
    writeVideo(v,CompleteFrame);
    RTFramecounter
end
close(v);
