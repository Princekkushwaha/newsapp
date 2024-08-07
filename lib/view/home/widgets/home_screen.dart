import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_news_app/bloc/News_bloc.dart';
import 'package:flutter_news_app/bloc/News_event.dart';
import 'package:flutter_news_app/bloc/News_state.dart';
import 'package:flutter_news_app/view/home/headlines_widget.dart';
import 'package:flutter_news_app/view/home/widgets/home_app_bar_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final format = DateFormat('MMMM dd, yyyy');

  @override
  void initState() {
    super.initState();
    context.read<NewsBloc>()..add(FetchNewsChannelHeadlines('bbc-news'));
    context.read<NewsBloc>()..add(NewsCategories('Sports'));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(59), child: HomeAppBarWidget()),
      body: ListView(
        physics: AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: height * .50,
            width: width,
            child: BlocBuilder<NewsBloc, NewsState>(
              builder: (BuildContext context, state) {
                switch (state.status) {
                  case Status.initial:
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: height * 0.50,
                        width: width,
                        color: Colors.white,
                      ),
                    );
                  case Status.failure:
                    return Center(
                      child: Text(state.message.toString()),
                    );
                  case Status.success:
                    return ListView.builder(
                      itemCount: state.newsList!.articles!.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        DateTime dateTime = DateTime.parse(state
                            .newsList!.articles![index].publishedAt
                            .toString());
                        return HeadlinesWidget(
                          dateAndTime: format.format(dateTime),
                          index: index,
                        );
                      },
                    );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: BlocBuilder<NewsBloc, NewsState>(
              builder: (BuildContext context, state) {
                switch (state.categoriesStatus) {
                  case Status.initial:
                    return Column(
                      children: List.generate(
                          3,
                          (index) => Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  height: height * .18,
                                  width: double.infinity,
                                  color: Colors.white,
                                  margin: EdgeInsets.only(bottom: 15),
                                ),
                              )),
                    );
                  case Status.failure:
                    return Center(
                      child: Text(state.categoriesMessage.toString()),
                    );
                  case Status.success:
                    return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: state.newsCategoriesList!.articles!.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        DateTime dateTime = DateTime.parse(state
                            .newsCategoriesList!.articles![index].publishedAt
                            .toString());
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: CachedNetworkImage(
                                  imageUrl: state.newsCategoriesList!
                                      .articles![index].urlToImage
                                      .toString(),
                                  fit: BoxFit.cover,
                                  height: height * .18,
                                  width: width * .3,
                                  placeholder: (context, url) =>
                                      Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      height: height * .18,
                                      width: width * .3,
                                      color: Colors.white,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Icon(
                                    Icons.error_outline,
                                    color: Color.fromARGB(255, 166, 59, 21),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: height * .18,
                                  padding: EdgeInsets.only(left: 15),
                                  child: Column(
                                    children: [
                                      Text(
                                        state.newsCategoriesList!
                                            .articles![index].title
                                            .toString(),
                                        maxLines: 3,
                                        style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      Spacer(),
                                      Row(
                                        mainAxisAlignment:
                                        
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              state.newsCategoriesList!
                                                  .articles![index].source!.name
                                                  .toString(),
                                              style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  color: Colors.black54,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          Text(
                                            format.format(dateTime),
                                            style: GoogleFonts.poppins(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    );
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
