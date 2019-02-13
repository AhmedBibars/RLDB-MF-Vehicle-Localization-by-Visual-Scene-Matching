# RLDB-MF-Vehicle-Localization-by-Visual-Scene-Matching

Vehicle visual localization by scene matching, using RLDB binary image descriptor and Markov filter.

This project introduces an algorithm for Vehicle visual localization by scene matching. The proposed visual localization approach assumes that the vehicle stores an annotated database image sequence. The database is created in a previous vehicle trip using a mounted camera, a displacement odometry sensor, and a GPS receiver. During the database image sequence creation phase, the moving vehicle covers all roads in the navigation area. Images for the vehicle surroundings are captured every one meter of displacement on the road. While during the real-time vehicle visual localization phase, only a mounted camera and displacement odometry sensor are used, while the GPS is not used. Each new captured real-time image is matched with the database images to get an estimation for the current location, at the same time the odometry sensors readings are used to enhance the accuracy of the final estimated location. A modified version of Markov localization filter is used as a data fusion algorithm, that integrates odometry sensor measurements with locations estimated form image matching process to get a final accurate estimation for the vehicle location at each filter cycle.

The algorithm performs accurate, fast, and appearance invariant scene matching using the Random Local Difference Binary image descriptor (RLDB). RLDB is a novel binary image descriptor that represents an extension for the state-of-the-art LDB descriptor, that enhances its matching accuracy and its computational efficiency. We have introduced ELDB in a separate project that you can find in the following link: https://github.com/AhmedBibars/ELDB-Binary-Image-Descriptor

The demos presented in this project measure the localization accuracy of the proposed vehicle visual localization algorithm. The datasets used are: 1- Highway dataset. 2- CBD dataset. Each of these datasets contains two videos, one is recorded at day time, while the other is recorded at nights. One of the two videos is considered as an image database, while the other is considered as a real-time image-queries.

The videos of the datasets are available at the following website of Queensland university of technology (QUT): https://wiki.qut.edu.au/display/cyphy/Datasets

For CBD dataset:<br />
"Demo_CBD_RLDB_MMF.m": measures localization accuracy in case of using the Modified Markov Filter (MMF).<br />
"Demo_CBD_RLDB_MMF.m": measures localization accuracy in case of using the regular Markov Filter (MF).<br />
"Demo_CBD_RLDB_SingleImageMatching.m": measures localization accuracy using only image matching, without Markov filter.<br />
At the end of each demo, a demo-video is generated using the function "GenerateResultVideo_CBD.m". Similar to the video in the following link: https://www.youtube.com/watch?v=IC-snqqX42g&t=1s <br />

For Highway dataset:<br />
"Demo_Highway_RLDB_MMF.m": measures localization accuracy in case of using the Modified Markov Filter (MMF).<br />
"Demo_Highway_RLDB_MMF.m": measures localization accuracy in case of using the regular Markov Filter (MF).<br />
"Demo_Highway_RLDB_SingleImageMatching.m": measures localization accuracy using only image matching, without Markov filter.<br />
At the end of each demo, a demo-video is generated using the function "GenerateResultVideo_Highway.m". Similar to the video in the following link: https://www.youtube.com/watch?v=r6ze6YNYIek&t=4s <br />


