class PlaceTest {
  final String place;
  // final String placeImage;
  // final String numRat;
  // final String numLon;

  const PlaceTest({
    required this.place,
    // required this.placeImage,
    // required this.numRat,
    // required this.numLon
  });
}

const List<PlaceTest> allPlace = [
  PlaceTest(
    place: "ตึกภาควิศวกรรมเครื่องกล EN10",
  ),
  PlaceTest(place: "ตึกภาควิศวกรรมไฟฟ้า EN11"),
  // Place(
  //     place: "อาคารปฏิบัติการวิศวกรรมเกษตร EN12", ),
  PlaceTest(
    place: "ตึกภาควิศวกรรมสิ่งแวดล้อม EN13",
  ),
  // Place(place: "ตึกภาควิศวกรรมเคมี EN14", numRat: "", numLon: "numLon"),
  // Place(place: "ตึกเพียรวิจิตร EN16", numRat: "", numLon: "numLon"),
  // Place(
  //     place: "อาคารปฏิบัติการวิศวกรรมอุตสาหการ EN17",
  //     numRat: "",
  //     numLon: "numLon"),
  PlaceTest(place: "อาคาร 50 ปี วิศวกรรมรวมใจ EN18")
];
