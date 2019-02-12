FrameSize1 = DBVidReadObj.Height;
FrameSize2 = DBVidReadObj.Width;
load CBDMap;
Map=insertShape(WarpMap,'Line',reshape(MapPoints(1:1714,:)',[1,2*1714]),'Color','r','LineWidth',4);
Map=insertShape(Map,'Line',reshape(MapPoints(1715:3129,:)',[1,2*1415]),'Color','r','LineWidth',4);
Map=insertShape(Map,'Line',reshape(MapPoints(3130:3545,:)',[1,2*416]),'Color','r','LineWidth',4);
Map=insertShape(Map,'Line',reshape(MapPoints(3546:3641,:)',[1,2*96]),'Color','r','LineWidth',4);

v = VideoWriter('Result_CBD.avi');
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
    Map=insertShape(Map,'FilledCircle',[CurrentLocation(RTFramecounter,1:2),2],'Color','y');
    ModifiedMap=insertShape(Map,'Circle',[CurrentLocation(RTFramecounter,1:2),20],'Color','y','LineWidth',6);
    ModifiedMap=insertMarker(ModifiedMap,CurrentLocation(RTFramecounter,1:2),'*','color','y','size',15);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    CompleteFrame=zeros(CompinedVideoFrameSize1+466,FrameSize2,3,'uint8');
    ModifiedMap=imresize(ModifiedMap,[466,867]);
    MapSize1=size(ModifiedMap,1);MapSize2=size(ModifiedMap,2);
    CompleteFrame(1:CompinedVideoFrameSize1,:,:)=CompinedVideoFrame;
    CompleteFrame(CompinedVideoFrameSize1+1:CompinedVideoFrameSize1+MapSize1,FrameSize2-MapSize2+1:FrameSize2,:)=ModifiedMap;%(29:494,88:954,:);
    
    CompleteFrame = insertText(CompleteFrame, [24 545], strcat('Cycle number: ',num2str(RTFramecounter)),'FontSize',38,'BoxColor','blue','BoxOpacity',0.4,'TextColor','white');
    CompleteFrame = insertText(CompleteFrame, [1 859], 'Top frame: Real-time query frame.                                                             ','FontSize',32,'BoxColor','blue','BoxOpacity',0.4,'TextColor','white');
    CompleteFrame = insertText(CompleteFrame, [1 902], 'Bottom frame: Nearest database frame to the estimated location.              ','FontSize',32,'BoxColor','blue','BoxOpacity',0.4,'TextColor','white');
    CompleteFrame = insertText(CompleteFrame, [1 945], 'Map: Estimated vehicle trajectory (Yellow), roads covered in database (red)','FontSize',32,'BoxColor','blue','BoxOpacity',0.4,'TextColor','white');

    if CorrectLocalization(RTFramecounter)==1
        CompleteFrame=insertText(CompleteFrame, [24 645], 'Correctly estimated location','FontSize',68,'BoxColor','green','BoxOpacity',0.4,'TextColor','white');
    else
        CompleteFrame=insertText(CompleteFrame, [24 645], 'Wrong location','FontSize',68,'BoxColor','red','BoxOpacity',0.4,'TextColor','white');
    end
%     imshow(CompleteFrame);
%     drawnow;
    writeVideo(v,CompleteFrame);
    %RTFramecounter
end
close(v);
