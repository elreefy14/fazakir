import 'package:fazakir/Features/sebha/data/models/sebha_zikr_model.dart';
import 'package:fazakir/Features/sebha/presentation/manager/cubits/manage_sebha_zikr_cubit/manage_sebha_zikr_cubit.dart';
import 'package:fazakir/core/utils/app_colors.dart';
import 'package:fazakir/core/utils/app_font_styles.dart';
import 'package:fazakir/core/widgets/custom_text_button.dart';
import 'package:fazakir/core/widgets/custom_form_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddZikrDialog extends StatelessWidget {
  const AddZikrDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(24),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.add_outlined,
            color: AppColors.primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            'اضافة ذكر',
            style: AppFontStyles.styleBold16(context),
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 210, 210, 210),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(16),
        ),
      ),
      actions: [
        CustomTextButton(
          text: 'إضافة الذكر',
          onPressed: () {
            if (context
                .read<ManageSebhaZikrCubit>()
                .formKeyAdd
                .currentState!
                .validate()) {
              context.read<ManageSebhaZikrCubit>().addSebhaZikr(
                    SebhaZikrModel(
                      zikr: context
                          .read<ManageSebhaZikrCubit>()
                          .textAddZikr
                          .text
                          .trim(),
                      count: int.parse(
                        context
                            .read<ManageSebhaZikrCubit>()
                            .textAddZikrCount
                            .text
                            .trim(),
                      ),
                    ),
                  );
              context.read<ManageSebhaZikrCubit>().clear();
              Navigator.pop(context);
            }
          },
        ),
      ],
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: context.read<ManageSebhaZikrCubit>().formKeyAdd,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomFormTextField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'برجاء ادخال الذكر';
                  }
                  return null;
                },
                controller: context.read<ManageSebhaZikrCubit>().textAddZikr,
                hintText: 'اكتب الذكر',
              ),
              const SizedBox(height: 24),
              CustomFormTextField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'برجاء ادخال عدد المرات';
                  }
                  return null;
                },
                controller:
                    context.read<ManageSebhaZikrCubit>().textAddZikrCount,
                keyboardType: TextInputType.number,
                hintText: 'عدد المرات',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showAddZikrDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => BlocProvider.value(
      value: context.read<ManageSebhaZikrCubit>(),
      child: const AddZikrDialog(),
    ),
  );
}
