DatabaseVideoPath='G:\SURF Features\Day.wmv';
RealTimeVideoPath='G:\SURF Features\Night.wmv';
Descriptor1=RLDB_Descriptor; % create object of the class
Descriptor1=Descriptor1.SelectRandomCellPairs_UD;  %randomly select cell-pairs
FrameCropStart=7;FrameCropEnd=172; %interest area in the frame (vertical limits).
FrontFrameRange=1:512;RearFrameRange=513:1024;
Side1FrameRange=1025:1536;Side2FrameRange=1537:2048;
load GroundTruth_CBD;  % groundtruth quary/database equivelant frames, to compare our results with it.
load('MapPoints_CBD.mat');
load PropagationMatrixes_CBD;%load Propoagation matrix.
MapScale=1;
%PropagationErrorCovariance=[0.05;0.9;0.05];  %Propagation error covariance.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
VehicleLocalizeMMF;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure;plot(CurrentImage);hold on
plot(GT(:,2),GT(:,1));
title('RLDB/MMF result');
xlabel('Quary frame number','FontSize', 20,'FontWeight','bold','Color','k');  % 'bold'/'normal'  'k'=black
ylabel('Database frame number','FontSize', 20,'FontWeight','bold','Color','k');
legend('Ground truth','Estimated trajectory','Location','Best');grid;
figure;plot(Recall,100*Precision);axis([0,100,0,100]);grid;
xlabel('Recall','FontSize', 20,'FontWeight','bold','Color','k');  % 'bold'/'normal'  'k'=black
ylabel('Precision','FontSize', 20,'FontWeight','bold','Color','k');

disp('Whould you like to generate a video showing the trip and the estimated vehicle location on the map? Y/N');
key = getkey;
if key==121
    disp('Generating the video. This will take a few minutes.')
    GenerateResultVideo_CBD;
end
% save('CBD_MMF_Result.mat','Result2D','CorrectLocalization','CurrentImage','Recall','Precision','LongestGap');