import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:trailapp/models/record_model.dart';
import 'package:trailapp/repositories/crud_repository.dart';

// Events
abstract class CrudEvent extends Equatable {
  const CrudEvent();
  @override
  List<Object?> get props => [];
}

class LoadRecords extends CrudEvent {}

class AddRecord extends CrudEvent {
  final String title;
  final File? image;
  final File? pdf;
  const AddRecord({required this.title, this.image, this.pdf});
  @override
  List<Object?> get props => [title, image, pdf];
}

class UpdateRecord extends CrudEvent {
  final String id;
  final String title;
  final File? image;
  final File? pdf;
  final String? existingImageUrl;
  final String? existingPdfUrl;
  const UpdateRecord({
    required this.id,
    required this.title,
    this.image,
    this.pdf,
    this.existingImageUrl,
    this.existingPdfUrl,
  });
  @override
  List<Object?> get props => [id, title, image, pdf, existingImageUrl, existingPdfUrl];
}

class DeleteRecord extends CrudEvent {
  final RecordModel record;
  const DeleteRecord(this.record);
  @override
  List<Object?> get props => [record];
}

// States
abstract class CrudState extends Equatable {
  const CrudState();
  @override
  List<Object?> get props => [];
}

class CrudInitial extends CrudState {}
class CrudLoading extends CrudState {}
class CrudLoaded extends CrudState {
  final List<RecordModel> records;
  const CrudLoaded(this.records);
  @override
  List<Object?> get props => [records];
}
class CrudSuccess extends CrudState {
  final String message;
  const CrudSuccess(this.message);
  @override
  List<Object?> get props => [message];
}
class CrudError extends CrudState {
  final String message;
  const CrudError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class CrudBloc extends Bloc<CrudEvent, CrudState> {
  final CrudRepository repository;

  CrudBloc({required this.repository}) : super(CrudInitial()) {
    on<LoadRecords>(_onLoadRecords);
    on<AddRecord>(_onAddRecord);
    on<UpdateRecord>(_onUpdateRecord);
    on<DeleteRecord>(_onDeleteRecord);
  }

  Future<void> _onLoadRecords(LoadRecords event, Emitter<CrudState> emit) async {
    emit(CrudLoading());
    try {
      final records = await repository.getRecords();
      emit(CrudLoaded(records));
    } catch (e) {
      emit(CrudError(e.toString()));
    }
  }

  Future<void> _onAddRecord(AddRecord event, Emitter<CrudState> emit) async {
    emit(CrudLoading());
    try {
      await repository.addRecord(
        title: event.title,
        image: event.image,
        pdf: event.pdf,
      );
      add(LoadRecords());
    } catch (e) {
      emit(CrudError(e.toString()));
    }
  }

  Future<void> _onUpdateRecord(UpdateRecord event, Emitter<CrudState> emit) async {
    emit(CrudLoading());
    try {
      await repository.updateRecord(
        id: event.id,
        title: event.title,
        image: event.image,
        pdf: event.pdf,
        existingImageUrl: event.existingImageUrl,
        existingPdfUrl: event.existingPdfUrl,
      );
      add(LoadRecords());
    } catch (e) {
      emit(CrudError(e.toString()));
    }
  }

  Future<void> _onDeleteRecord(DeleteRecord event, Emitter<CrudState> emit) async {
    emit(CrudLoading());
    try {
      await repository.deleteRecord(event.record);
      add(LoadRecords());
    } catch (e) {
      emit(CrudError(e.toString()));
    }
  }
}
