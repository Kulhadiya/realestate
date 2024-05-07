import 'package:ebroker/Ui/screens/project/view/project_list_screen.dart';
import 'package:ebroker/data/cubits/project/fetch_projects.dart';
import 'package:ebroker/data/model/project_model.dart';
import 'package:ebroker/utils/guestChecker.dart';
import 'package:flutter/material.dart';

import '../../../Ui/screens/widgets/AnimatedRoutes/blur_page_route.dart';
import '../../../Ui/screens/widgets/blurred_dialoge_box.dart';
import '../../../exports/main_export.dart';
import '../../../utils/ui_utils.dart';

class AllProjectsScreen extends StatefulWidget {
  const AllProjectsScreen({super.key});

  static Route route(RouteSettings settings) {
    return BlurredRouter(
      builder: (context) {
        return const AllProjectsScreen();
      },
    );
  }

  @override
  State<AllProjectsScreen> createState() => _AllProjectsScreenState();
}

class _AllProjectsScreenState extends State<AllProjectsScreen> {
  final ScrollController _controller = ScrollController();
  @override
  void initState() {
    _controller.addListener(() {
      if (_controller.isEndReached()) {
        if (context.read<FetchProjectsCubit>().hasMore()) {
          context.read<FetchProjectsCubit>().fetchMoreProjects();
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UiUtils.buildAppBar(context,
          showBackButton: true, title: UiUtils.translate(context, "projects")),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: BlocBuilder<FetchProjectsCubit, FetchProjectsState>(
          builder: (context, state) {
            if (state is FetchProjectsSuccess) {
              return Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(14),
                    itemCount: state.projects.length,
                    itemBuilder: (context, index) {
                      ProjectModel project = state.projects[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            GuestChecker.check(
                              onNotGuest: () {
                                if (context
                                        .read<FetchSystemSettingsCubit>()
                                        .getRawSettings()['is_premium'] ??
                                    false) {
                                  Navigator.pushNamed(
                                      context, Routes.projectDetailsScreen,
                                      arguments: {"project": project});
                                } else {
                                  UiUtils.showBlurredDialoge(context,
                                      dialoge: BlurredDialogBox(
                                          title: "Subscription needed",
                                          isAcceptContainesPush: true,
                                          onAccept: () async {
                                            Navigator.popAndPushNamed(
                                                context,
                                                Routes
                                                    .subscriptionPackageListRoute,
                                                arguments: {"from": "home"});
                                          },
                                          content: const Text(
                                              "Subscribe to package if you want to use this feature")));
                                }
                              },
                            );
                          },
                          child: ProjectCard(
                              categoryName: project.category?.category ?? "",
                              url: project.image ?? "",
                              title: project.title ?? "",
                              description: project.description ?? "",
                              categoryIcon: project.category?.image ?? "",
                              status: project.type ?? ""),
                        ),
                      );
                    },
                  ),
                  if (state.isLoadingMore) UiUtils.progress()
                ],
              );
              // return ProjectCard(categoryName: categoryName, url: url, title: title, description: description, categoryIcon: categoryIcon, status: status);
            }
            return Container();
          },
        ),
      ),
    );
  }
}
